# AWS Serverless Infrastructure with Terraform

Este repositorio contiene el despliegue automatizado de una arquitectura **Serverless** en AWS (emulada con **LocalStack**) utilizando **Terraform**. El proyecto demuestra la gestión de infraestructura como código, permisos de mínimo privilegio y procesamiento de eventos con AWS Lambda.

## 📐 Flujo de la arquitectura

```
subir_archivo.py → sube objeto a S3 Bucket (laboratorio-de-noe-2026)
                          ↓
                  evento s3:ObjectCreated
                          ↓
                  AWS Lambda (SaludoLambda)
                          ↓
        lee el archivo subido y devuelve su tamaño procesado
```

La Lambda recibe el evento de S3, obtiene el bucket y la key del objeto, descarga su contenido con `boto3`, y devuelve una confirmación con el tamaño del archivo procesado.

## 🚀 Componentes de la arquitectura

- **Amazon S3:** bucket para almacenamiento de objetos y disparo de eventos.
- **AWS Lambda:** función en Python que se activa automáticamente al subirse un archivo al bucket, lo lee y lo procesa.
- **AWS IAM:** rol para la Lambda con permisos de mínimo privilegio (`s3:GetObject` sobre el bucket específico, más permisos de logging en CloudWatch).
- **Amazon DynamoDB:** tabla adicional (`UsuariosIT`) desplegada como parte del laboratorio de infraestructura.
- **Infrastructure as Code (IaC):** todo el entorno se define y despliega con Terraform.
- **Scripts de automatización:** `subir_archivo.py` para cargar archivos al bucket vía `boto3`.

## 🛠️ Herramientas utilizadas

- **Terraform** — orquestación de infraestructura
- **LocalStack** — emulación local de servicios AWS
- **AWS CLI** — verificación e invocación manual de recursos
- **Python 3.9** (`boto3`) — lógica de la Lambda y scripts de soporte
- **Git / GitHub** — control de versiones

## 📁 Estructura del repositorio

```
.
├── main.tf              # Recursos: S3, Lambda, IAM, DynamoDB, trigger
├── hola_lambda.py        # Código de la función Lambda
├── subir_archivo.py      # Script para subir archivos al bucket S3
├── function.zip           # Paquete de despliegue de la Lambda
├── evento_prueba.json    # Evento S3 simulado, para invocación manual
└── README.md
```

## ⚙️ Requisitos previos

- Terraform
- LocalStack corriendo (por ejemplo vía Docker)
- AWS CLI
- Python 3.9+ con `boto3` instalado

## 🚀 Cómo desplegarlo

```bash
terraform init
terraform plan
terraform apply
```

Cada vez que se modifica el código de la Lambda (`hola_lambda.py`), hay que reempaquetarlo antes de aplicar:

```powershell
Compress-Archive -Path hola_lambda.py -DestinationPath function.zip -Force
terraform apply
```

*(El recurso usa `source_code_hash` para detectar automáticamente cambios en el código y actualizar la Lambda desplegada.)*

## ▶️ Cómo probarlo

**1. Subir un archivo (dispara el evento S3):**
```bash
python subir_archivo.py
```

**2. Verificar el procesamiento:**

Nota: en este entorno de LocalStack (edición Community), el disparo automático de la Lambda vía notificación S3 no siempre es confiable — es una limitación documentada del emulador, no del código. Para validar la lógica de negocio de forma determinística, la función se invoca también de forma manual simulando el evento real de S3:

```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name SaludoLambda \
  --payload file://evento_prueba.json \
  --cli-binary-format raw-in-base64-out \
  --region us-east-1 \
  respuesta.json

cat respuesta.json
```

Salida esperada:
```json
{"statusCode": 200, "body": "Archivo 'mi_primer_log.txt' procesado correctamente. Tamano: 74 caracteres."}
```

**3. Revisar logs de ejecución:**
```bash
aws --endpoint-url=http://localhost:4566 logs describe-log-streams \
  --log-group-name /aws/lambda/SaludoLambda --region us-east-1
```

## 🔐 Seguridad

- El rol IAM de la Lambda (`iam_for_lambda`) sigue el principio de mínimo privilegio: solo tiene permiso `s3:GetObject` sobre el bucket `laboratorio-de-noe-2026` (no acceso de escritura ni a otros buckets), más los permisos mínimos de CloudWatch Logs necesarios para logging.
- El bucket solo otorga permiso de invocación (`lambda:InvokeFunction`) al servicio S3 (`s3.amazonaws.com`), restringido al ARN del bucket específico, evitando invocaciones no autorizadas desde otras fuentes.
- Las credenciales usadas son las de prueba de LocalStack (`test`/`test`), sin equivalente en una cuenta AWS real.

## 🧹 Limpieza de recursos

```bash
terraform destroy
```

## 📚 Aprendizajes

Este proyecto forma parte de mi formación técnica en Análisis de Sistemas y especialización en Cloud Computing (certificaciones AWS Cloud Practitioner y Google Cloud Computing Foundations). Además de la infraestructura en sí, el proceso de debugging fue parte central del aprendizaje: detectar que el trigger automático no se disparaba, diferenciar si el problema era del código o del emulador, y validar la lógica mediante invocación manual del evento simulado.

---

**Noelia D'Andrea**
[LinkedIn](https://www.linkedin.com/in/noelia-d-andrea-b25545242) | [Credly](https://www.credly.com/users/noelia-d-andrea)