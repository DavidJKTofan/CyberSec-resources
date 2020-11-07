## Terminal (Shell) Profiles

Change to Z Shell:
```
chsh -s /bin/zsh
```

Open Z Shell CONFIG file:
```
nano ~/.zshrc
```

Bash Shell:
```
chsh -s /bin/bash
```

Open Bash Shell CONFIG file:
```
nano ~/.bashrc
```

*****

## Block access to specific Websites on Mac

Open Terminal
```sudo nano /etc/hosts```

Add:
0.0.0.0    www.website.com

Click Control + O and hit Enter
Click Control + X to exit

Flush local DNS cache:
```sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache```

*****

## Delete Icon from Launchpad

```
sqlite3 $(sudo find /private/var/folders -name com.apple.dock.launchpad)/db/db "DELETE FROM apps WHERE title=‘APPNAME’;” && killall Dock
```

LOCATION:
```
/System/Library/CoreServices/Dock.app/Contents/Resources/LaunchPadLayout.plist
```

*****

## Delete TimeMachine Snapshots

SEE ALL SNAPSHOTS:
```
tmutil listlocalsnapshots /
```

EXAMPLE:
```
sudo tmutil deletelocalsnapshots 2020-03-16-093306
```

```
sudo tmutil thinlocalsnapshots / 999999999999
```

*****

## Check Downloaded file SHA256
Check for Malware

TERMINAL
```
shasum -a 256 PATH_TO_FILE
```

Alternative: [Minisign](https://jedisct1.github.io/minisign/) or [Free Formatter](https://www.freeformatter.com/)

*****

## List Open Ports
### Network Sockets

```netstat -nr```

```netstat -ap tcp | grep -i "listen"```
```sudo lsof -PiTCP -sTCP:LISTEN```
```lsof -Pn -i4```

```netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;colred="\033[01;31m";colclr="\033[0m"; print cred "proto: " colclr $1 colred " | addr.port: " colclr $4 colred " | pid: " colclr $9 colred " | name: " colclr procname;  }' | column -t -s "|"```

```netstat -ap tcp```

### See all connected Devices

```arp -a```

### See all open Connections

```lsof -i```
```lsof -i | grep -E "(LISTEN|ESTABLISHED)"```

*****

## Check if System Integrity Protection (SIP) is enabled

```csrutil status```

*****

## Disable Remote SSH

```sudo systemsetup -setremotelogin off```

*****

## Check Email Reputation

```curl -s emailrep.io/name@domain.com```

*****

## Disable IPv6

```networksetup -setv6off Wi-Fi```

### Re-enable IPv6

```networksetup -setv6automatic Wi-Fi```

*****

## Check Internet Speed Test

```sudo apt install speedtest-cli && speedtest-cli```

```sudo snap install fast && fast```

*****

## Programming

Create a virtual environment (venv):
```
python3 -m venv DIRECTORY_NAME
```

Active the virtual environment:
```
source DIRECTORY_NAME/bin/activate
```

Install packages (specific version):
```
python -m pip install requests==2.6.0
```

Display all packages installed in the virtual environment:
```
pip list
```

Create a requirements.txt file with all installed packages (incl. version info):
```pip freeze > requirements.txt```

Install all packages listed inside the requirements.txt file:
```
pip install -r requirements.txt
```

*****
