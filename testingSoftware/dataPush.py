import mysql.connector
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
import time

# Generate RSA keys (you can save and reuse these keys for consistency)
def generate_rsa_keys():
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
    )
    public_key = private_key.public_key()
    return private_key, public_key

# Sign data with the private key
def sign_data(private_key, data):
    signature = private_key.sign(
        data.encode(),  # Encode data to bytes
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH,
        ),
        hashes.SHA256(),
    )
    return signature

# Upload data to MySQL
def upload_to_database(temperature, humidity, signature):
    try:
        # Connect to the database
        connection = mysql.connector.connect(
            host="localhost",
            user="fireproof",  # Replace with your database username
            password="safepass",  # Replace with your database password
            database="tData",  # Replace with your database name
        )

        cursor = connection.cursor()

        # Insert data into the database
        

