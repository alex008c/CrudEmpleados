"""
BFF Lambda - Proxy entre ALB y API Gateway
Conecta el Application Load Balancer con el API Gateway del CRUD
"""

import json
import urllib.request
import urllib.error
import urllib.parse

# URL del API Gateway (CRUD backend)
API_GATEWAY_URL = "https://sv2ern4elf.execute-api.us-east-1.amazonaws.com"

def handler(event, context):
    """
    Handler que actúa como proxy entre ALB y API Gateway
    
    Flujo: ALB → Lambda BFF → API Gateway → Lambda CRUD → DB/SNS/SQS/Email
    """
    print(f"[BFF] Event recibido del ALB: {json.dumps(event)}")
    
    # Extraer información del request del ALB
    path = event.get('path', '/')
    http_method = event.get('httpMethod', 'GET')
    headers = event.get('headers', {})
    query_params = event.get('queryStringParameters', {})
    body = event.get('body', '')
    
    # Health check del BFF
    if path == '/health' or path == '/bff/health':
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'status': 'healthy',
                'service': 'bff-lambda',
                'message': 'ALB → BFF connection successful',
                'api_gateway': API_GATEWAY_URL
            })
        }
    
    # Redirigir todas las demás peticiones al API Gateway
    try:
        # Construir URL completa
        target_url = f"{API_GATEWAY_URL}{path}"
        
        # Agregar query parameters si existen
        if query_params:
            query_string = urllib.parse.urlencode(query_params)
            target_url = f"{target_url}?{query_string}"
        
        print(f"[BFF] Proxying {http_method} request to: {target_url}")
        
        # Preparar headers para el API Gateway
        api_headers = {
            'Content-Type': headers.get('content-type', 'application/json'),
            'User-Agent': 'BFF-Lambda-Proxy'
        }
        
        # Copiar Authorization header si existe
        if 'authorization' in headers:
            api_headers['Authorization'] = headers['authorization']
        
        # Crear request
        if body and http_method in ['POST', 'PUT', 'PATCH']:
            data = body.encode('utf-8') if isinstance(body, str) else body
            req = urllib.request.Request(
                target_url,
                data=data,
                headers=api_headers,
                method=http_method
            )
        else:
            req = urllib.request.Request(
                target_url,
                headers=api_headers,
                method=http_method
            )
        
        # Realizar request al API Gateway
        with urllib.request.urlopen(req, timeout=30) as response:
            response_body = response.read().decode('utf-8')
            response_status = response.status
            
            print(f"[BFF] Response from API Gateway: {response_status}")
            
            return {
                'statusCode': response_status,
                'headers': {
                    'Content-Type': 'application/json',
                    'X-Proxy-By': 'BFF-Lambda'
                },
                'body': response_body
            }
    
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        print(f"[BFF] HTTP Error {e.code}: {error_body}")
        
        return {
            'statusCode': e.code,
            'headers': {'Content-Type': 'application/json'},
            'body': error_body
        }
    
    except urllib.error.URLError as e:
        print(f"[BFF] URL Error: {str(e)}")
        
        return {
            'statusCode': 502,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'error': 'Bad Gateway',
                'message': f'Error connecting to API Gateway: {str(e)}'
            })
        }
    
    except Exception as e:
        print(f"[BFF] Unexpected error: {str(e)}")
        
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'error': 'Internal Server Error',
                'message': str(e)
            })
        }
