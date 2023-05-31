locals {
  default_tags = {
    ManagedBy   = "Terraform"
    Application = "test-app"
    Owner       = "daniel.tarff"
    GitRepo     = "github.com/org/test-app"
    Environment = var.environment
  }
}
