resource "aws_ecr_repository" "my_repository" {
  name = var.api_name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "my_repository_worker" {
  name = "${var.api_name}-worker"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
