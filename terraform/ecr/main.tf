resource "aws_ecr_repository" "app" {
  name = var.ecr_repository_name

  tags = {
    Name = "${var.name_prefix}-ecr"
  }
}