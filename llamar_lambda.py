import boto3
import json

# Conexión a tu nube local
lambda_client = boto3.client('lambda', 
                             endpoint_url='http://127.0.0.1:4566',
                             aws_access_key_id='test',
                             aws_secret_access_key='test',
                             region_name='us-east-1')

# El "paquete" de datos que le enviamos a la Lambda
datos = {"nombre": "Noe"}

print("Enviando datos a la Lambda...")

try:
    respuesta = lambda_client.invoke(
        FunctionName='SaludoLambda',
        Payload=json.dumps(datos) # Python convierte el diccionario a JSON solito
    )
    
    # Leemos lo que nos respondió el robot
    resultado = json.loads(respuesta['Payload'].read())
    print("\n--- Respuesta de la Lambda ---")
    print(resultado['body'])
    print("------------------------------")

except Exception as e:
    print(f"❌ Error al llamar a la Lambda: {e}")