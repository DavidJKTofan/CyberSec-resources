# CHALLENGE DESCRIPTION

You are after an organised crime group which is responsible for the illegal weapon market in your country. As a secret agent, you have infiltrated the group enough to be included in meetings with clients. During the last negotiation, you found one of the confidential messages for the customer. It contains crucial information about the delivery. Do you think you can decrypt it?

***
***

1. Downloaded the attached ZIP file and extracted the content.

2. We'll be able to see HOW the secret message was encrypted by looking at the the ```chall.py``` file. 

The mathematical formula to encrypt is ```(123 * char + 18) % 256```. Unfourtunately, the modulus operator makes it almost impossible to reverse engineer, which suggests that we should use a brute force approach.

The characters are passed through the ```bytes()``` function, which returns a bytes object, which then goes through the Python built-in hex function. The ```hex()``` function converts an integer number to the corresponding hexadecimal string.

3. After some research, we find out that the ```binascii.unhexlify()``` returns the binary string that is represented by any hexadecimal string, which is essentially the reverse of ```hex()```.

We will read the encrypted message and convert it back to bytes from hexidecimal.

4. The code.

To summarize: we open the original message ```msg.enc```, using ```binascii.unhexlify()``` to return the binary string, and apply our ```reverse_func()``` function to iterate over each character, which includes the original mathematical formula to encrypt ```encrypt()```, and ultimately gives us the flag in string format.

```
import binascii

with open("msg.enc") as message:
    msg = binascii.unhexlify(message.read())
    deciphered_message = reverse_func(msg)
    print('Flag: ', deciphered_message)
```
```
def encrypt(char):
    return (123 * char + 18) % 256
```
```
def reverse_func(msg):
    original_msg = []
    for byte in msg:
        # All printable characters (1–128)
        for i in range(1, 129):
            # Apply encryption formula
            encrypted = encrypt(i)
            if encrypted == byte:
                original_msg.append(chr(i))
    return ''.join(original_msg)
```
