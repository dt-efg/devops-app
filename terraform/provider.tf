provider "aws" {
  alias  = "euc1"
  region = "eu-central-1"

  default_tags {
    tags = local.default_tags
  }
}
