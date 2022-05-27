terraform {
  backend "s3" {
    bucket = "mb-infra-remote-state"
    key    = "mbpage-app.tfstate"
    region = "us-east-1"
  }
}
