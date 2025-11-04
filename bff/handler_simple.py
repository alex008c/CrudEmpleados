"""
BFF Lambda simplificado - Solo para demostración del ALB
Sin dependencias complejas para evitar problemas de compatibilidad
"""

def handler(event, context):
    """
    Handler para Lambda invocado por ALB
    """
    print(f"Event recibido del ALB: {event}")
    
    # El ALB envía el request en un formato específico
    path = event.get('path', '/')
    http_method = event.get('httpMethod', 'GET')
    
    if path == '/health':
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': '{"status":"healthy","service":"bff-lambda","message":"ALB connection successful"}'
        }
    
    # Endpoint raíz
    if path == '/':
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': '{"message":"BFF Lambda is working via ALB","endpoints":["/health","/"]}'
        }
    
    # Ruta no encontrada
    return {
        'statusCode': 404,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': '{"error":"Not found","path":"' + path + '"}'
    }
