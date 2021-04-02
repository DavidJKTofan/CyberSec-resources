# Source: https://youtu.be/StmNWzHbQJU
import request
import threading

'''
Use-Case: Credit Card Transaction declines
Valid TEST card numbers:
#4007000000027
#5555555555554444 Mastercard
#5105105105105100 Mastercard
#4111111111111111 Visa
#4012888888881881 Visa
Source: https://docs.adyen.com/development-resources/test-cards/test-card-numbers
'''

'''
COPY-PASTE FROM CHROME
Go to Inspect > Network >
> Select the Request with the correct Form Data (credit card info) >
> Copy-paste the URL to the url variable and the Form Data to the data variable
'''

# Request URL
url = ''

data = {
    # COPY-PASTE FROM CHROME
    # > Form Data

}

# Infinite loop
def do_reuqest():
    while True:
        # Post form data to url
        response = requests.post(url, data=data)  # allow_redirects=False
        print(reponse)

threads = []

# Run 50 threads all at once
for i in range(50):
    t = threading.Thread(target=do_reuqest)
    t.daemon = True
    threads.append(t)

for i in range(50):
    threads[i].start()

for i in range(50):
    threads[i].join()
