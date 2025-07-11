terraform {
  backend "s3" {
    # Replace with your bucket name from the CLI command
    bucket       = "tfstate-bucket-solo-c589de05-52dd-42a6-a34e-a9c3a03d7ca0"
    key          = "tfstate/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}