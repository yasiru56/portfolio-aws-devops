provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "portfolio-aws-devops"
      ManagedBy = "terraform"
      Owner     = "yasiru"
    }
  }
}