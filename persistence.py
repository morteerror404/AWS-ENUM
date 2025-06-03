import os
import requests

# Proper path formatting (raw string or double backslashes)
aws_credentials_path = r"C:\users\frota\home\.aws\credentials"

url = input("Enter the URL to make a curl request: ")

# Example of making a request (without exposing credentials)
try:
    response = requests.get(url)
    print(response.text)
except requests.RequestException as e:""
    print(f"Error making request: {e}")