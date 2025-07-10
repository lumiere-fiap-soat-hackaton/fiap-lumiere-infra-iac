locals {
  lambda_prefix = join("", [for s in split("-", var.project_name) : title(s)])

  # Number of messages to pull in one batch (1-10)
  lambda_batch_size = 5

  # //////// values for auth lambda functions ////////
  common_environment_variables = {
    NODE_ENV           = var.environment
    LOG_LEVEL          = var.log_level
    BUCKET_NAME        = var.bucket_name
    AUTH_CLIENT_ID     = var.auth_client_id
    AUTH_CLIENT_SECRET = var.auth_client_secret
  }

  # Define lambda-functions functions with their properties to avoid repetition
  lambda_functions = {
    authorizer = {
      name = "authorizer"
    }
    signUp = {
      name = "sign-up"
    }
    signIn = {
      name = "sign-in"
    }
    signOut = {
      name = "sign-out"
    }
    userData = {
      name = "user-data"
    }
    userRecords = {
      name = "user-records"
    }
    storageUrl = {
      name = "storage-url"
    }
  }

  # Create a mapping of artifact file paths for each function
  artifacts_path = {
    for func_key, func_data in local.lambda_functions :
    func_key => "${var.artifacts_zip_path}/${func_key}.zip"
  }
}