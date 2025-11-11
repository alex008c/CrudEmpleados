import json
import logging
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Cliente de SES
ses_client = boto3.client('ses', region_name='us-east-1')

# Email verificado que usaremos como remitente
SENDER_EMAIL = "alexfrank.af04@gmail.com"

def lambda_handler(event, context):
    logger.info(f"Procesando {len(event['Records'])} mensajes de EventBridge/SQS")
    
    for record in event['Records']:
        try:
            # Parsear el body (puede venir directo de EventBridge o de SNS)
            body_content = json.loads(record['body'])
            
            # Si tiene 'Message' es de SNS, si no, es directo de EventBridge
            if 'Message' in body_content:
                # Formato SNS: body -> Message -> datos
                email_data = json.loads(body_content['Message'])
            else:
                # Formato EventBridge: body -> datos directos
                email_data = body_content
            
            to = email_data.get('to')
            subject = email_data.get('subject')
            body = email_data.get('body')
            
            logger.info("=" * 60)
            logger.info("ENVIANDO CORREO REAL CON AMAZON SES")
            logger.info("=" * 60)
            logger.info(f"De: {SENDER_EMAIL}")
            logger.info(f"Para: {to}")
            logger.info(f"Asunto: {subject}")
            logger.info(f"Cuerpo: {body}")
            
            # Enviar email real con SES
            response = ses_client.send_email(
                Source=SENDER_EMAIL,
                Destination={
                    'ToAddresses': [to]
                },
                Message={
                    'Subject': {
                        'Data': subject,
                        'Charset': 'UTF-8'
                    },
                    'Body': {
                        'Text': {
                            'Data': body,
                            'Charset': 'UTF-8'
                        }
                    }
                }
            )
            
            logger.info("=" * 60)
            logger.info(f"✅ Correo enviado correctamente!")
            logger.info(f"Message ID: {response['MessageId']}")
            logger.info("=" * 60)
            
        except ClientError as e:
            logger.error(f"❌ Error de SES: {e.response['Error']['Message']}")
            logger.error(f"Código de error: {e.response['Error']['Code']}")
            raise
        except Exception as e:
            logger.error(f"❌ Error procesando mensaje: {str(e)}")
            logger.error(f"Contenido del registro: {record}")
            raise
    
    return {
        'statusCode': 200,
        'body': json.dumps({'processed': len(event['Records'])})
    }
