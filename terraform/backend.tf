terraform {
  backend "s3" {
    bucket = "wikijs-conf"
    key    = "wikijs.tfstate"
    region = "eu-west-1"
  }
}
