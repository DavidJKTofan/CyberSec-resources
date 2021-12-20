# TryHackMe: Wifi Hacking 101

_Learn to attack WPA(2) networks! Ideally you'll want a smartphone with you for this, preferably one that supports hosting wifi hotspots so you can follow along._

[Wifi Hacking 101](https://tryhackme.com/room/wifihacking101)

* * * * * 
* * * * *

## Info

The `aircrack-ng` suite consists of:

```
aircrack-ng
airdecap-ng
airmon-ng
aireplay-ng
airodump-ng
airtun-ng
packetforge-ng
airbase-ng
airdecloak-ng
airolib-ng
airserv-ng
buddy-ng
ivstools
easside-ng
tkiptun-ng
wesside-ng
```

[Linux man page](https://linux.die.net/man/1/aircrack-ng)

## Questions

Put the interface "wlan0" into monitor mode with Aircrack:_
```
airmon-ng start wlan0
```

The interface name will change from "wlan0" to "wlan0mon".

If other processes are currently trying to use that network adapter:
```
airmon-ng check kill
```

Create a capture:
```
airodump-ng
```

Using the `rockyou` wordlist, crack the password in the attached capture (download the files from the website) by running:
```
aircrack-ng -b 02:1A:11:FF:D9:BD -w /usr/share/wordlists/rockyou.txt NinjaJc01-01.cap
```