resource "aws_appautoscaling_target" "ecs" {
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.devops_app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  max_capacity       = 3
  min_capacity       = 1
}

# ECS CPU target tracking autoscaling rule

resource "aws_appautoscaling_policy" "cpu_scale_out" {
  name               = "cpu-scale-out"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}

# ECS service scheduled scale-in and scale-out
# Runs 08:00-18:00UTC Mon-Fri

resource "aws_appautoscaling_scheduled_action" "scale_in" {
  name               = "ecs-scale-in"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  schedule           = "cron(0 8 ? * 1-5 *)"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_out" {
  name               = "ecs-scale-out"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  schedule           = "cron(0 18 ? * 1-5 *)"

  scalable_target_action {
    min_capacity = aws_appautoscaling_target.ecs.min_capacity
    max_capacity = aws_appautoscaling_target.ecs.max_capacity
  }
}
