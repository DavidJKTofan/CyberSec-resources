# Cryptocurrency Mining on a Raspberry Pi (RPi)

I followed the guide on [NetworkChuck](https://youtu.be/hHtGN_JzoP8)'s YouTube tutorial. This is merely a _dirty_ transcript.

* * * * * * * * 

## RPi OS

Download the latest ZIP file on https://downloads.raspberrypi.org/raspios_lite_arm64/images/

Unziping it will show the image file.

## SD Card

Download the Raspberry Pi Imager on https://www.raspberrypi.com/software/

Open the Raspberry Pi Imager, select ```use custom``` and choose the image we just downloaded.

```CTL + SHIFT + X``` to open the secret menu in order to do our headless install by choosing ```Enable SSH```, set a password for the ```pi``` user, and configure your WiFi, unless you use hardwire.

Then click write.

## RPi Update

Insert the SD Card into the RPi and turn it on.

Your router will assign an IP address to the RPi, use it to SSH into it: ```ssh pi@IP_ADDRESS```

First step, update: ```sudo apt update && sudo apt dist-upgrade && sudo apt full-upgrade && sudo apt autoremove -y && sudo apt autoclean && sudo apt clean```

## RPi Install Packages

Install the necessary packages: ```sudo apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y```

Clone the repository and change into that directory: ```git clone https://github.com/xmrig/xmrig.git```

Create a new directory and change into that directory: ```mkdir build```

Install the program by building it from the source: ```cmake ..``` and ```make```

## Wallet

Prepare a Wallet by going to https://www.getmonero.org/, and download and install the Monero GUI Wallet.

Launch the Monero GUI Wallet (you might get a notification from your Antivirus that it tries to connect to the Internet, allow, if you want to use it).

Use the Simple Mode, and create a new Wallet, and SAVE your ```Mnemonic seed``` somewhere safe! And create a safe password for it.

Click on the Account tab, and copy your Wallet Address.

## Start Mining

Using a mining pool makes it _easier_ to mine, so we use a mining pool.

Ready? Type into your RPi: ```./xmrig -o gulf.moneroocean.stream:10128 -u YOUR_WALLET_ADDRESS_HERE -p YOUR_LABEL```

As soon as you hit enter, your RPi starts to mine!

## Check

Hit the letter ```h``` to see your Hashrate (speed), how many guesses you are making.

Hit the letter ```s``` to see if we helped finish a job and how many shares we got.

Hit the letter ```c``` to see the current connection.

* * * * * * * * 

# Disclaimer

This is for educational and informative purposes only. It is essentially what was displayed in the YouTube video shown at the beginning. You are at your own risk when doing anything, and this is in no way to encourage anyone to start mining cryptocurrency. This is not financial advice.
