resource "aws_secretsmanager_secret" "secret" {
  name = var.secret-name
}

resource "aws_secretsmanager_secret_version" "secret-version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret-value
}