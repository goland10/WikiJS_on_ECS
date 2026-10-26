terraform {
  backend "s3" {
    bucket = "wikijs-on-ecs-goland10"
    key    = "wikijs.tfstate"
    region = "eu-west-1"
  }
}
