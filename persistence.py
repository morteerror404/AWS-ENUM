import requests

# Caminho correto para as credenciais AWS (usando raw string)
aws_credentials_path = r"C:\users\frota\home\.aws\credentials"

url = input("Digite a URL para fazer a requisição: ")

# Fazendo a requisição com tratamento de erros adequado
try:
    response = requests.get(url)
    print(response.text)
except requests.RequestException as e:
    print(f"Erro na requisição: {e}")