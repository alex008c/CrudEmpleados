import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Procesando {len(event['Records'])} mensajes de SQS")
    
    for record in event['Records']:
        try:
            sns_message = json.loads(record['body'])
            email_data = json.loads(sns_message['Message'])
            
            to = email_data.get('to')
            subject = email_data.get('subject')
            body = email_data.get('body')
            
            logger.info("=" * 60)
            logger.info("SIMULACION DE ENVIO DE CORREO")
            logger.info("=" * 60)
            logger.info(f"Enviando correo a: {to}")
            logger.info(f"Asunto: {subject}")
            logger.info(f"Cuerpo: {body}")
            logger.info("=" * 60)
            logger.info("Correo enviado correctamente")
            logger.info("=" * 60)
            
        except Exception as e:
            logger.error(f"Error procesando mensaje: {str(e)}")
            logger.error(f"Contenido del registro: {record}")
            raise
    
    return {
        'statusCode': 200,
        'body': json.dumps({'processed': len(event['Records'])})
    }
