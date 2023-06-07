resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.app_name}-cluster"
}

resource "aws_ecs_service" "devops_app_service" {
  name                              = local.app_name
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.devops_app.arn
  launch_type                       = "FARGATE"
  desired_count                     = 3
  health_check_grace_period_seconds = 300

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.devops_app.family
    container_port   = 8080
  }

  network_configuration {
    subnets         = local.private_subnet_ids
    security_groups = [aws_security_group.ecs.id]
  }
}

resource "aws_ecs_task_definition" "devops_app" {
  family                   = local.app_name
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${local.app_name}",
      "image": "${aws_ecr_repository.ecr_repo.repository_url}",
      "essential": true,
      "environment": [
        {
          "name": "POSTGRESQL_HOST",
          "value": "${module.rds.db_instance_address}"
        },
        {
          "name": "POSTGRESQL_DBNAME",
          "value": "${module.rds.db_instance_name}"
        },
        {
          "name": "POSTGRESQL_USERNAME",
          "value": "${module.rds.db_instance_username}"
        },
        {
          "name": "POSTGRESQL_PASSWORD",
          "value": "${module.rds.db_instance_password}"
        }
      ],
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": 512,
      "cpu": 256,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${local.app_name}",
          "awslogs-region": "eu-central-1",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "${local.app_name}"
        }
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.task_execution_role.arn
}

resource "aws_iam_role" "task_execution_role" {
  name               = "taskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
