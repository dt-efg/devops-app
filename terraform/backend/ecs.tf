module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.0.1"

  cluster_name = "ecs-integrated"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    ecsdemo-frontend = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {

        fluent-bit = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
          firelens_configuration = {
            type = "fluentbit"
          }
          memory_reservation = 50
        }

        ecs-sample = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          dependencies = [{
            containerName = "fluent-bit"
            condition     = "START"
          }]

          enable_cloudwatch_logging = false
          log_configuration = {
            logDriver = "awsfirelens"
            options = {
              Name                    = "firehose"
              region                  = "eu-west-1"
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }

      load_balancer = {
        service = {
          target_group_arn = aws_alb_target_group.target_group.arn
          container_name   = "ecs-sample"
          container_port   = 80
        }
      }

      subnet_ids = local.private_subnet_ids
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = aws_security_group.allow_http.id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}
