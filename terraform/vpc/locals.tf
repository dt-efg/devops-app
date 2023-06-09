locals {
  default_tags = {
    ManagedBy   = "Terraform"
    Application = "devops-app"
    Owner       = "daniel.tarff"
    GitRepo     = "github.com/dt-efg/devops-app"
    Environment = var.environment
  }
}
