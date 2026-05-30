terraform {
  backend "s3" {
    bucket       = "justauth-tfstate-1780169845"
    key          = "just-auth/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}