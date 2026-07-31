provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    lambda   = "http://localhost:4566"
    iam      = "http://localhost:4566"
  }
}

# --- BUCKET S3 ---
resource "aws_s3_bucket" "mi_bucket" {
  bucket = "laboratorio-de-noe-2026"
}

# --- TABLA DYNAMODB ---
resource "aws_dynamodb_table" "mi_tabla" {
  name         = "UsuariosIT"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"
  attribute {
    name = "UserId"
    type = "S"
  }
}

# --- ROL IAM PARA LA LAMBDA ---
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# --- FUNCIÓN LAMBDA ---
resource "aws_lambda_function" "mi_primera_lambda" {
  filename          = "function.zip"
  function_name     = "SaludoLambda"
  role              = aws_iam_role.iam_for_lambda.arn
  handler           = "hola_lambda.handler"
  runtime           = "python3.9"
  source_code_hash  = filebase64sha256("function.zip")
}

# --- PERMISO: S3 PUEDE INVOCAR LA LAMBDA ---
resource "aws_lambda_permission" "permitir_s3_invocar_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mi_primera_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::laboratorio-de-noe-2026"
}

# --- TRIGGER: EL BUCKET DISPARA LA LAMBDA AL SUBIR UN ARCHIVO ---
resource "aws_s3_bucket_notification" "trigger_lambda_en_upload" {
  bucket = aws_s3_bucket.mi_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.mi_primera_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.permitir_s3_invocar_lambda]
}

# --- PERMISOS: LA LAMBDA PUEDE LEER DEL BUCKET Y ESCRIBIR LOGS ---
resource "aws_iam_role_policy" "permisos_lectura_s3" {
  name = "permitir_lectura_bucket"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::laboratorio-de-noe-2026/*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}