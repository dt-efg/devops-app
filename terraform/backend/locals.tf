locals {
  app_name = "devops-app"

  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  default_tags = {
    ManagedBy   = "Terraform"
    Application = "devops-app"
    Owner       = "daniel.tarff"
    GitRepo     = "github.com/dt-efg/devops-app"
    Environment = var.environment
  }
}
