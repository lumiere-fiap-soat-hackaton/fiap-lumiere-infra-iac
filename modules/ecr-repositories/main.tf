resource "aws_ecr_repository" "this" {
  name                 = "${var.project_name}-video-processor"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "this" {
  name                 = "${var.project_name}-web-front"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}