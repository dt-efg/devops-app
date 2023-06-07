provider "aws" {
  region = "eu-central-1"
  #shared_credentials_files = ["~/.aws/credentials"]
  #profile = "default"

  default_tags {
    tags = local.default_tags
  }
}
