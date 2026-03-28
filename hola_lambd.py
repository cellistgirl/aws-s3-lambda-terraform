def handler(event, context):
    nombre = event.get("nombre", "Invitado")
    mensaje = f"¡Hola {nombre}! Soy una función Lambda ejecutándose en LocalStack 🚀"
    
    return {
        "statusCode": 200,
        "body": mensaje
    }