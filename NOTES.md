# Terraform commands

## Run terraform plan
tf plan -out tfplan

## target specific resource
tf plan -target module.s3_buckets -target module.sqs_queues -out tfplan

## apply plan
tf apply tfplan

## format files
tf fmt -recursive