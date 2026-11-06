resource "aws_ecr_repository" "mi-catalogo-repo" {
  name                 = "mi-catalogo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" {
  value = aws_ecr_repository.mi-catalogo-repo.repository_url
}