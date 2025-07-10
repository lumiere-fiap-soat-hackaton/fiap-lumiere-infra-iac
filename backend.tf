terraform {
  backend "s3" {
    # Replace with your bucket name from the CLI command
    bucket       = "tfstate-bucket-solo-4c07eb68-575a-4450-82c7-c488d75e373b"
    key          = "tfstate/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}