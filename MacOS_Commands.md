
A brief overview on some tools, packages and commands that help you secure or understand better your macOS operating system.

_Disclaimer: Some of the tools, packages and/or commands may or may not work with only specific macOS versions._<br>
_This is for educational purposes only._

# Table of Contents
[Homebrew & pip](#update)  
[Python3 Paths](#python)  
[Python Programming](#programming)  
[Shell Terminal](#shell)  
[Edit DNS Hosts File](#hosts)  
[Delete Icons on Launchpad](#launchpad)  
[Time Machine Snapshots](#timemachine)  
[Checksum Files](#sha256)  
[Network Ports](#ports)  
[System Integrity Protection](#sip)  
[SSH Protocol](#ssh)  
[Email Reputation](#emailrep)  
[IPv6](#ipv6)  
[Internet Speed](#speed)  
[Auditing](#audits)  
[DNS over HTTPS](#doh)  
[Convert Images](#webp)  
[MAC Address](#mac)  
[Random Passwords](#randompw)
[Download GIFs](#download)  
[OWASP Favicon Database](#owaspfavicon)  

*****
*****

<a name="update"></a>
## Update

Update brew, pip, outdated pip modules, brew cleanup, brew doctor, update npm, update nvm:
```
brew update && brew upgrade && pip install --upgrade pip && pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U && brew cleanup && brew doctor && brew cleanup && echo success && npm update -g && nvm install "lts/*" --reinstall-packages-from="$(nvm current)"
```

*****

<a name="python"></a>
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

<a name="programming"></a>
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

<a name="shell"></a>
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

<a name="hosts"></a>
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

<a name="launchpad"></a>
## Delete Icon from Launchpad

```
sqlite3 $(sudo find /private/var/folders -name com.apple.dock.launchpad)/db/db "DELETE FROM apps WHERE title=‘APPNAME’;” && killall Dock
```

LOCATION:
```
/System/Library/CoreServices/Dock.app/Contents/Resources/LaunchPadLayout.plist
```

*****

<a name="timemachine"></a>
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

<a name="sha256"></a>
## Check Downloaded file SHA256
Check for Malware

TERMINAL
```
shasum -a 256 PATH_TO_FILE
```

Alternative: [Minisign](https://jedisct1.github.io/minisign/) or [Free Formatter](https://www.freeformatter.com/)

*****

<a name="ports"></a>
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

<a name="sip"></a>
## Check if System Integrity Protection (SIP) is enabled

```
csrutil status
```

*****

<a name="ssh"></a>
## Disable Remote SSH

```
sudo systemsetup -setremotelogin off
```

*****

<a name="emailrep"></a>
## Check Email Reputation

```
curl -s emailrep.io/name@domain.com
```

*****

<a name="ipv6"></a>
## Disable IPv6

```
networksetup -setv6off Wi-Fi
```

### Re-enable IPv6

```
networksetup -setv6automatic Wi-Fi
```

*****

<a name="speed"></a>
## Check Internet Speed Test

```
sudo apt install speedtest-cli && speedtest-cli
```

```
sudo snap install fast && fast
```

*****

<a name="wifi"></a>
## WiFi Passwords

View saved WiFi password of WIFI_NAME:
```
security find-generic-password -ga "WIFI_NAME" | grep “password:”
```

*****

<a name="audits"></a>
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

<a name="doh"></a>
## DNS over HTTPS

### Cloudflared

Install cloudflared using homebrew:
```
brew install cloudflare/cloudflare/cloudflared
```

Create /usr/local/etc/cloudflared/config.yaml, with the following content:
```
proxy-dns: true
proxy-dns-port: 53
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
  #Uncomment below if you want to also want to use IPv6 for external DoH lookups
  #- https://[2606:4700:4700::1111]/dns-query
  #- https://[2606:4700:4700::1001]/dns-query
```

Activate cloudflared as a service:
```
sudo cloudflared service install
```

Change your DNS settings (System Preferences -> Network -> Advanced -> DNS) to:
```
127.0.0.1
```

Test if it is connected on https://1.1.1.1/help

_Source: [soderlind](https://gist.github.com/soderlind/6a440cd3c8e017444097cf2c89cc301d) _

*****

<a name="webp"></a>
## Convert Images to WebP

Make sure you have ```webp``` installed on your macOS:
```
brew install webp
```

```cd``` into the folder where your images (.jpg or .png) are located and copy-paste into your terminal:
```
for F in *.jpg; do cwebp $F -o `basename ${F%.jpg}`.webp; done
```

_NOTE: The code is for .jpg files. If you want to convert .png files to .webp, simply change .jpg to .png._

*****

<a name="mac"></a>
## Change MAC address

In terminal:
```
ifconfig en0 | grep ether
```

Create new MAC address:
```
openssl rand -hex 6 | sed ‘s/\(..\)/\1:/g; s/.$//’
```

Copy-paste the new MAC Address (replacing x):
```
sudo ifconfig en0 ether xx:xx:xx:xx:xx:xx
```

*****

<a name="randompw"></a>
## Create Random Passwords

Copy-paste into your terminal:
```
openssl rand -base64 200
```

_NOTE: change the value 200 to change the lenght of the password._

*****

<a name="download"></a>
## Download GIFs

Use cURL to download GIFs from Giphy:
```
curl https://media4.giphy.com/media/xUA7aUNw61j9Vdzs0U/giphy.gif --output ~/Desktop/download.gif
```

*****

<a name="owaspfavicon"></a>
## OWASP Favicon Database

Check Website's Favicon and compare with the [OWASP Favicon Database](https://wiki.owasp.org/index.php/OWASP_favicon_database):
```
curl https://www.cf-testing.com/favicon.png -o output.png | md5
curl https://www.cf-testing.com/favicon.png | md5
```

*****
