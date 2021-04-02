# Source: https://youtu.be/UtNYzv8gLbs
# Works for almost any simple login/register form.

import requests
import os
import random
import string
import json

# Random characters
chars = string.ascii_letters + string.digits + '!@#$%^&*()'
random.seed = (os.urandom(1024))

'''
COPY-PASTE FROM CHROME
Go to Inspect > Network >
> Select the Request with the correct Form Data (username and password) >
> Copy-paste the URL to the url variable and the Form Data to the data variable
'''

# Request URL
url = ''

# Load names
names = json.loads(open('names.json').read())  # External file

# Loop through all names
for name in names:

	# Create extra digits for the username
	name_extra = ''.join(random.choice(string.digits))
	# Create usernames
	username = name.lower() + name_extra + '@yahoo.com'  # gmail.com

	# Random password length
	pw_length = random.randint(8,16)
	# Create a random password
	password = ''.join(random.choice(chars) for i in range(pw_length))

	# Post the form-data to the url
	requests.post(url, allow_redirects=False, data={
		'FORM-DATA-1': username, 	# Add the correct Form Data
		'FORM-DATA-2': password  	# Add the correct Form Data
	})

	# Making sure it's working
	print 'sending username %s and password %s' % (username, password)
