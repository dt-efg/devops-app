resource "aws_ecr_repository" "ecr_repo" {
  name = local.app_name
}
