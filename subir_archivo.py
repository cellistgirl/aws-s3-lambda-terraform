import boto3
import os

# Configuración de conexión (la misma que te dio éxito antes)
s3 = boto3.client('s3', 
                  endpoint_url='http://127.0.0.1:4566',
                  aws_access_key_id='test',
                  aws_secret_access_key='test',
                  region_name='us-east-1')

bucket_nombre = "laboratorio-de-noe-2026"

# 1. Creamos un archivo de prueba rápido
nombre_archivo = "mi_primer_log.txt"
with open(nombre_archivo, "w") as f:
    f.write("Este es un archivo subido por Noe a su propia nube local. ¡Misión cumplida!")

print(f"Subiendo {nombre_archivo} al bucket {bucket_nombre}...")

# 2. Subida oficial
try:
    s3.upload_file(nombre_archivo, bucket_nombre, nombre_archivo)
    print("✅ ¡ARCHIVO SUBIDO CON ÉXITO!")
    
    # 3. Listar contenido para verificar
    print("\nContenido actual del bucket:")
    objetos = s3.list_objects_v2(Bucket=bucket_nombre)
    for obj in objetos.get('Contents', []):
        print(f" - {obj['Key']} ({obj['Size']} bytes)")

except Exception as e:
    print(f"❌ Error al subir: {e}")

    # Crear un Rol (permiso) para la Lambda
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

# Crear la función Lambda
resource "aws_lambda_function" "mi_primera_lambda" {
  filename      = "function.zip"
  function_name = "SaludoLambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "hola_lambda.handler" # Archivo hola_lambda, función handler
  runtime       = "python3.9"
}