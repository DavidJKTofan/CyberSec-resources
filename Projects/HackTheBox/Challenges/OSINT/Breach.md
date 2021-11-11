# CHALLENGE DESCRIPTION

You managed to pull some interesting files off one of Super Secure Startup's anonymous FTP servers. Via some OSINT work(a torrent or online Password breach site) you have also procured a recent data breach dump. Can you unlock the file and retrieve the key?

***
***

1. Downloaded the attached ZIP file and extracted the content.

2. Checking the information on the ```key.docx``` file gives away that it was modified on the ```26th of March 2019```, and remembering _Bianka_ from the prior challenge ```We Have a Leak```, the password turned up to be ```Love!March2019```, which will give us an encrypted SSH Key for a root user.

3. That encrypted SSH key looks like base64, which we can decode on a terminal with ```echo SFRCe1A0c3N3MHJkX0JyM2FjaDNzX0M0bl9CM19BX1RyM2FzdXIzX1Ryb3YzXzBmX0luZjBybWF0aTBufQ== | base64 --decode```, and this will return us the flag.