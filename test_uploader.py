import requests
import hmac
import hashlib
import time

# Define the secret key
secret_key = b'verysafepostpwd'

while True:
    # Set temp and hum as floats with two decimal places
    temp = round(20.0, 2)
    hum = round(20.0, 2)
    sum_value = round(temp + hum, 2)

    # Format sum as a float with two decimal places
    message = "{:.2f}".format(sum_value).encode('UTF-8')
    generated_hash = hmac.new(secret_key, message, hashlib.sha256).hexdigest()

    # Debug: Print intermediate values for comparison
    print(f"Python Debug - temp: {temp}, hum: {hum}, sum: {sum_value}")
    print(f"Python Debug - Message: {message.decode()}")
    print(f"Python Debug - Secret key (hex): {secret_key.hex()}")
    print(f"Python Debug - Generated Hash (HMAC): {generated_hash}")

    # Perform the GET request with the generated hash
    url = f"http://fireproofservices.ddns.net/scripts/push_data.php?temp={temp}&hum={hum}&key={generated_hash}"
    print("Ran GET request on: " + url)
    request = requests.get(url)
    print("Return: " + str(request.text))  # Print the response content for more detail

    # Wait before the next iteration
    time.sleep(3)

