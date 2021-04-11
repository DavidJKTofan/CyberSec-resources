## Update

Update brew, pip, outdated pip modules, brew cleanup, brew doctor:
```
brew update && brew upgrade && pip install --upgrade pip && pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U && brew cleanup && brew doctor && brew cleanup && echo success
```

*****

## Install Python

Install [Homebrew](https://brew.sh/):
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Install Python3:
```
brew install python3
```

List installed Python packages:
```
brew list | grep python
```

Show info on Python package:
```
brew info python
```

Update Homebrew and Python package:
```
brew update && brew upgrade python
```

Create an alias to use Python3:
```
alias python=/usr/local/bin/python3     # Or the path info that was shown when running `brew info python` or `which python3`
```

Show pip3 version:
```
pip3 -V
```

Show path info of pip3:
```
which pip3
```

Add aliases to the Terminal:
```
echo "alias pip=/usr/local/bin/pip3" >> ~/.zshrc 
# or for BASH
echo "alias pip=/usr/local/bin/pip3" >> ~/.bashrc
```

*****

## Python Programming

### Virtual Environment
#### venv

Create a virtual environment (venv) with python3:
```
python3 -m venv PROJECT_NAME -p python3
python3.8 -m venv PROJECT_NAME  # For a specific Python version
```

Active the virtual environment:
```
source PROJECT_NAME/bin/activate
```

Deactive virtual environment:
```
deactivate
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
```
pip freeze > requirements.txt
```

Install all packages listed inside the requirements.txt file:
```
pip install -r requirements.txt
```

Install Jupyter Notebook, and install new Jupyter Notebook kernel:
```
pip install jupyter
ipython kernel install --user --name=PROJECT_NAME
```

Check the kernel JSON file so that it is pointing to your virtual environment python version (/bin/python3):
``` 
/Users/`whoami`/Library/Jupyter/kernels/
```

Display all kernels, and uninstall kernel:
```
jupyter kernelspec list
jupyter kernelspec uninstall project_name
```

Delete virtual environment:
```
rm -rf PROJECT_NAME
```

*****

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
```
sudo nano /etc/hosts
```

Add:
```
0.0.0.0    www.website.com
```
Click Control + O and hit Enter
Click Control + X to exit

Flush local DNS cache:
```
sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache
```

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

```
netstat -nr
```

```
netstat -ap tcp | grep -i "listen"
```
```
sudo lsof -PiTCP -sTCP:LISTEN
```
```
lsof -Pn -i4
```

```
netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;colred="\033[01;31m";colclr="\033[0m"; print cred "proto: " colclr $1 colred " | addr.port: " colclr $4 colred " | pid: " colclr $9 colred " | name: " colclr procname;  }' | column -t -s "|"
```

```
netstat -ap tcp
```

### See all connected Devices

```
arp -a
```

### See all open Connections

```
lsof -i
```
```
lsof -i | grep -E "(LISTEN|ESTABLISHED)"
```

*****

## Check if System Integrity Protection (SIP) is enabled

```
csrutil status
```

*****

## Disable Remote SSH

```
sudo systemsetup -setremotelogin off
```

*****

## Check Email Reputation

```
curl -s emailrep.io/name@domain.com
```

*****

## Disable IPv6

```
networksetup -setv6off Wi-Fi
```

### Re-enable IPv6

```
networksetup -setv6automatic Wi-Fi
```

*****

## Check Internet Speed Test

```
sudo apt install speedtest-cli && speedtest-cli
```

```
sudo snap install fast && fast
```

*****

## WiFi Passwords

View saved WiFi password of WIFI_NAME:
```
security find-generic-password -ga WIFI_NAME | grep “password:”
```

*****

## Auditing, system hardening, compliance testing
_Lynis is a battle-tested security tool for systems running Linux, macOS, or Unix-based operating system_
Documentation: https://cisofy.com/documentation/lynis/get-started/

Download Lynis:
```
brew install lynis  # Also available through Git: git clone https://github.com/CISOfy/lynis
```

```
cd lynis
```

Perform a quick security scan:
```
./lynis audit system -Q
```

*****

## DNS over HTTPS

### Cloudflared

Install cloudflared using homebrew:
```
brew install cloudflare/cloudflare/cloudflared
```

Create /usr/local/etc/cloudflared/config.yaml, with the following content:
```
proxy-dns: true
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
```

Activate cloudflared as a service:
```
sudo cloudflared service install
```

Change your DNS settings (System Preferences -> Network -> Advanced -> DNS) to:
```
127.0.0.1
```

_Source: https://gist.github.com/soderlind/6a440cd3c8e017444097cf2c89cc301d _

*****
