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
# 1. Le damos permiso a S3 para invocar la Lambda
resource "aws_lambda_permission" "permitir_s3_invocar_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mi_primera_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::laboratorio-de-noe-2026"
}

# 2. Configuramos el bucket para que dispare la Lambda cuando se sube un objeto
resource "aws_s3_bucket_notification" "trigger_lambda_en_upload" {
  bucket = "laboratorio-de-noe-2026"

  lambda_function {
    lambda_function_arn = aws_lambda_function.mi_primera_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.permitir_s3_invocar_lambda]
}

# --- Nota sobre permisos del rol de la Lambda ---
# El rol actual (iam_for_lambda) solo tiene el assume_role_policy (quién puede
# usar el rol), pero no una política de permisos (qué puede HACER el rol).
# Como el nuevo handler va a leer el objeto de S3, conviene agregar esto también:

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
