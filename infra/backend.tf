terraform {
  backend "s3" {
    bucket       = "yasiru-tfstate-093736401854"
    key          = "portfolio/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}