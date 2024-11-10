import requests, random, time, hmac, hashlib
import hmac
import hashlib


secret_key = b'verysafepostpwd'




while True:
    temp = random.random()*10+20
    hum = random.random()*10+20

    message = str(hum).encode('UTF-8') 
    hash = hmac.new(secret_key, message, hashlib.sha256).hexdigest()
    


    print(f"Generated Hash (HMAC): {hash}")
    print(f"Message: {message.decode()}")





    url = f"http://192.168.1.116/scripts/push_data.php?temp={temp}&hum={hum}&key={hash}"
    print("Ran get request on: " + url)
    request = requests.get(url)
    print("return: " + str(request))
    time.sleep(3)

