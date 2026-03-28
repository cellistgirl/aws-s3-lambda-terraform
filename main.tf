provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  # AGREGA ESTA LÍNEA MÁGICA:
  s3_use_path_style           = true
      
  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
  }
}

# Crear un Bucket de S3
resource "aws_s3_bucket" "mi_bucket" {
  bucket = "laboratorio-de-noe-2026"
}

# Crear una Tabla de Base de Datos
resource "aws_dynamodb_table" "mi_tabla" {
  name         = "UsuariosIT"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }
}