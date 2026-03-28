import boto3

# Usamos la IP directa para evitar fallos de nombre
url = 'http://127.0.0.1:4566'

s3 = boto3.client('s3', 
                  endpoint_url=url, 
                  aws_access_key_id='test', 
                  aws_secret_access_key='test', 
                  region_name='us-east-1')

try:
    buckets = s3.list_buckets()
    print("✅ ¡CONEXIÓN EXITOSA!")
    print("Tus buckets son:")
    for b in buckets['Buckets']:
        print(f" - {b['Name']}")
except Exception as e:
    print(f"❌ ERROR DE CONEXIÓN: {e}")