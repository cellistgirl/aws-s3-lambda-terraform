import boto3
import os

# Para LocalStack: apuntamos al endpoint local
s3 = boto3.client(
    's3',
    endpoint_url=os.environ.get('AWS_ENDPOINT_URL', 'http://host.docker.internal:4566'),
    region_name='us-east-1'
)


def handler(event, context):
    # El evento de S3 llega con la info del archivo subido en 'Records'
    record = event['Records'][0]
    bucket_nombre = record['s3']['bucket']['name']
    archivo_key = record['s3']['object']['key']

    print(f"📥 Evento recibido: se subió '{archivo_key}' al bucket '{bucket_nombre}'")

    # Leemos el contenido del archivo recién subido
    respuesta = s3.get_object(Bucket=bucket_nombre, Key=archivo_key)
    contenido = respuesta['Body'].read().decode('utf-8')

    print(f"📄 Contenido del archivo: {contenido}")

    mensaje = f"Archivo '{archivo_key}' procesado correctamente. Tamaño: {len(contenido)} caracteres."

    return {
        "statusCode": 200,
        "body": mensaje
    }
