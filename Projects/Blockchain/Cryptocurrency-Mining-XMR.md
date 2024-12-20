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
(check out the [command line options](https://xmrig.com/docs/miner/command-line-options))

Create a new directory and change into that directory: ```cd xmrig``` and ```mkdir build``` and ```cd build```

_NOTE: if you want to disable the donation feature (which you shouldn't), you can go on ```/src/donate.h``` and change the values of ```kDefaultDonateLevel = 1``` and ```kMinimumDonateLevel = 1``` to ```0```._

Install the program by building/compiling it from the source: ```cmake ..``` and ```make```

## Wallet

Prepare a Wallet by going to https://www.getmonero.org/, and download and install the Monero GUI Wallet.

Launch the Monero GUI Wallet (you might get a notification from your Antivirus that it tries to connect to the Internet, allow, if you want to use it).

Use the Simple Mode, and create a new Wallet, and SAVE your ```Mnemonic seed``` somewhere safe! And create a safe password for it.

Click on the Account tab, and copy your Wallet Address.

:) My Wallet Address: _476Hss9ziDEg5gNqmGZR2KRVRQDsBbD8E58scVcUzRbRaxSxTPmY66LbRTghXu3MYD61B4vmDLXGHXCMpkX21MvRKiPk4UX_

## Start Mining

Using a mining pool makes it _easier_ to mine, so we use a mining pool.

Ready? Type into your RPi: ```./xmrig -o gulf.moneroocean.stream:10128 -u YOUR_WALLET_ADDRESS_HERE -p YOUR_LABEL```

As soon as you hit enter, your RPi starts to mine!

## Start at boot

If you want to start XMRig at boot, create a systemd block: ```nano /etc/systemd/system/xmrig.service```

The content would like something like this:
```
[Unit]
Description=XMRig Daemon
After=network.target
[Service]
User=pi
Group=pi
Type=simple
ExecStart=/home/pi/xmrig/build/xmrig -o gulf.moneroocean.stream:10128 -u YOUR_WALLET_ADDRESS_HERE -p YOUR_LABEL
Restart=always
[Install]
WantedBy=multi-user.target
```

On the other hand, one can also create a JSON config file with most parameters already set up:
```ExecStart=/home/pi/xmrig/build/xmrig --config=/home/pi/xmrig/src/config.json```
_NOTE: You can use the official [Config Wizard](https://xmrig.com/wizard#start) from XMRig._

Reload processes, enable boot-start and start service: ```systemctl daemon-reload``` and ```systemctl enable --now xmrig.service``` and ```systemctl start xmrig.service```

To view logs: ```journalctl -u xmrig.service```

## Check

Hit the letter ```h``` to see your **hashrate** (speed), how many guesses you are making.

Hit the letter ```s``` to see the **results**, if we helped finish a job and how many shares we got.

Hit the letter ```c``` to see the current **connection**.

Hit the letter ```p``` to **pause** mining.

Hit the letter ```r``` to **resume** mining.

Copy-paste your Wallet address to view how much you have already mined: ```https://moneroocean.stream/```

* * * * * * * * 

## Analysis

In average, one **Raspberry Pi 4 Model B 4GB RAM** achieves around 0.0006 XMR (€0.13) per month (as of 1st of December 2021). 
So not really worth it, is it? But what if we have a cluster? Hmm...

## My Monero Wallet

XMR Wallet Address: _476Hss9ziDEg5gNqmGZR2KRVRQDsBbD8E58scVcUzRbRaxSxTPmY66LbRTghXu3MYD61B4vmDLXGHXCMpkX21MvRKiPk4UX_

* * * * * * * * 

# Disclaimer

This is for educational and informative purposes only. It is essentially what was displayed in the YouTube video shown at the beginning. You are at your own risk when doing anything, and this is in no way to encourage anyone to start mining cryptocurrency. This is not financial advice.
