terraform {
  backend "s3" {
    # Replace with your bucket name from the CLI command
    bucket       = "tfstate-bucket-solo-ad5debf7-9158-4b48-a157-ca60847d5dc7"
    key          = "tfstate/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}