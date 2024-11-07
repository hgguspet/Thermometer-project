import requests, random, time


while True:
    temp = random.random()*10+20
    hum = random.random()*10+20

    url = f"http://localhost/scripts/push_data.php?temp={temp}&hum={hum}"
    print("Ran get request on: " + url)
    request = requests.get(url)
    time.sleep(3)

