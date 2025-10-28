import os
import json
import boto3

sns = boto3.client('sns')

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        
        to = body.get('to')
        subject = body.get('subject')
        message_body = body.get('body')
        
        if not all([to, subject, message_body]):
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'error': 'Faltan campos requeridos: to, subject, body'})
            }
        
        topic_arn = os.environ.get('SNS_TOPIC_ARN')
        if not topic_arn:
            return {
                'statusCode': 500,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'error': 'SNS_TOPIC_ARN no configurado'})
            }
        
        message = {
            'to': to,
            'subject': subject,
            'body': message_body
        }
        
        response = sns.publish(
            TopicArn=topic_arn,
            Message=json.dumps(message),
            Subject=subject
        )
        
        print(f"Mensaje publicado a SNS: {response['MessageId']}")
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'success': True,
                'messageId': response['MessageId']
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': str(e)})
        }
