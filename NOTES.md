# Terraform commands

## Run terraform plan
tf plan -out tfplan

## target specific resource
tf plan -target module.s3_buckets -target module.sqs_queues -out tfplan

## apply plan
tf apply tfplan

## Apply with var
tf apply -var ecs_service_desired_count=1 -auto-approve

## format files
tf fmt -recursive