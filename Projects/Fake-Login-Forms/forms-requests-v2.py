import requests
import json
import names
import random
import string
import time

url = ""
emails = ["gmail.com", "gmx.net", "web.de", "yahoo.com", "hotmail.com", "aol.com", "hotmai.co.uk", "hotmail.fr", "msn.com", "yahoo.fr", "wanadoo.fr", "orange.fr", "comcast.net", "yahoo.co.uk", "yahoo.com.br", "yahoo.co.in", "live.com", "rediffmail.com", "free.fr"]
counter = 0

def send_random_request():
    global counter
    email = names.get_full_name().replace(" ", ".") + "@" + random.choice(emails)
    password = ''.join(random.choice(string.ascii_letters+string.digits) for i in range(random.randint(8,12)))
    payload = {"email":email,"password":password}
    result = requests.post(url, allow_redirects=False, data=payload)
    counter += 1
    print(f"Sending No.{counter}: {email} and {password}")
    print(result)


if __name__ == "__main__":
    while True:
        send_random_request()
        time.sleep(random.randint(1,1000)/10)
