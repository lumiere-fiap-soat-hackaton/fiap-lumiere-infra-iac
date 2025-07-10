terraform {
  backend "s3" {
    # Replace with your bucket name from the CLI command
    bucket       = "tfstate-bucket-solo-16b181be-8e72-4bf3-8f30-6c49fd1c9f42"
    key          = "tfstate/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}