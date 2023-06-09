data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    region  = "eu-central-1"
    bucket  = "terraform-statebucket-xcf5pp0l7t0n"
    key     = "infra/vpc/dev.tfstate"
    profile = "default"
  }
}
