resource "aws_ecr_repository" "lumiere-video-processor" {
  name                 = "lumiere-video-processor"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}