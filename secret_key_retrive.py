import json
import boto3
from botocore.exceptions import ClientError

def get_secret():
    secret_name = "rds-postgres-credentials_3"
    region_name = "ap-south-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    # SecretString is returned as a string
    secret_string = get_secret_value_response['SecretString']
    
    # Parse the JSON string into a Python dictionary
    secret_dict = json.loads(secret_string)
    
    # Return the dictionary or a specific key like username
    return secret_dict

# Example Usage:
secret_credentials = get_secret()
print(secret_credentials)
print(type(secret_credentials))

# Access specific keys securely
db_name = secret_credentials.get('username') 
password = secret_credentials.get('password')
host = secret_credentials.get('host')
port = secret_credentials.get('port')
user = secret_credentials.get('engine')