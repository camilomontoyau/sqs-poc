resource "aws_ecr_repository" "my_repository" {
  name = "${var.main_name}-repository"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
