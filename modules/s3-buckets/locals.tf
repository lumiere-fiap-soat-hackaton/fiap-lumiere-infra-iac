locals {
  buckets = {
    source_files = {
      name_suffix = "source-files"
      name_tag    = "Source Files Bucket"
      queue_arn   = var.source_files_events_queue
      # Flags to conditionally create associated resources
      apply_lifecycle = true
      apply_cors      = true
    },
    result_files = {
      name_suffix = "result-files"
      name_tag    = "Result Files Bucket"
      queue_arn   = var.result_files_events_queue
      # These resources do not apply to this bucket
      apply_lifecycle = false
      apply_cors      = false
    }
  }

  # Create filtered maps for resources that only apply to a subset of buckets
  buckets_with_lifecycle = {
    for key, config in local.buckets : key => config if config.apply_lifecycle
  }
  buckets_with_cors = {
    for key, config in local.buckets : key => config if config.apply_cors
  }
}