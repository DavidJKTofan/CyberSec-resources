A brief overview on some packages and commands that help you secure your Linux operating system.

_Disclaimer: Some of the packages and/or commands may or may not work and/or vary in certain Linux distributions._<br>
_This is for educational purposes only._

***

# Table of Contents
[Sync Time](#time)  
[System Update](#update)  
[User Management](#users)  
[Permissions](#permissions)  
[Startup Services](#startup)  
[Network Parameters](#network)  
[DNS over HTTPS](#dns)  
[Uncomplicated Firewall](#ufw)  
[SSH](#ssh)  
[SELinux](#selinux)  
[Disable USB Usage](#blacklist)  
[Uninstall Unused Packages](#deborphan)  
[Encrypt/Decrypt Files](#encryption)  
[MAC Address](#mac)  
[Random Passwords](#randompw)  
[NGINX](#nginx)  

***
***

<a name="time"></a>

## Sync Time

View status:
```
timedatectl
systemctl status systemd-timesyncd.service
```

Edit CONFIG file:
```
sudo nano /etc/systemd/timesyncd.conf
```

Example of a CONFIG file:
```
[Time]
NTP=http://time.google.com/
FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
#RootDistanceMaxSec=5
#PollIntervalMinSec=32
#PollIntervalMaxSec=2048
```

Enable remote NTP server sync:
```
sudo timedatectl set-ntp true
```

Restart service:
```
sudo systemctl restart systemd-timesyncd.service
```

If the clock still does not sync, then try the following:
Install NTP package, enable the NTP service, and enable remote NTP server sync:
```
sudo apt install ntp
sudo systemctl enable ntp
sudo timedatectl set-ntp true
```


***

<a name="update"></a>

## System Update

Update all (system, libraries, dependencies, etc.):
```
sudo apt update && sudo apt dist-upgrade && sudo apt full-upgrade && sudo apt autoremove -y && sudo apt autoclean && sudo apt clean
```

```
sudo apt-get update && sudo apt-get upgrade -y
```

View installed packages:
```
sudo apt-cache pkgnames
```

Reboot:
```
sudo reboot
```

### Automatic System Updates

Install [`unattended-upgrades`](https://wiki.debian.org/UnattendedUpgrades) package:
```
sudo apt install unattended-upgrades
```

Enable `unattended-upgrades`:
```
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

Check if package is running:
```
sudo systemctl status unattended-upgrades.service
```

Package CONFIG files:
```
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

Test if the auto-upgrades work by launching a dry run:
```
sudo unattended-upgrades --dry-run --debug
```

Package logs located in:
```
/var/log/unattended-upgrades/
```


****

<a name="users"></a>

## User Management


Create a new user (`sudo` only necessary if you are not root user):
```
sudo adduser USERNAME
```

Add user to sudo group:
```
sudo usermod -aG sudo USERNAME
```
```
sudo usermod -aG GROUP USERNAME
```

Change user password:
```
psswd USERNAME
```

View group membership:
```
id USERNAME
```

****

<a name="permissions"></a>

## Permissions

<img src="/Images/linux-permissions.png" width="600" alt="Linux Permissions">

```
chown root:root /etc/anacrontab       # Change ownership to user root and group root
chmod og-rwx /etc/anacrontab          # Allow users who are not owners of this file, and users who are part of this files' group to rwx

chown root:root /etc/crontab
chmod og-rwx /etc/crontab

chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly

chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily

chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly

chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly

chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d
```

```
chown root:root <crontabfile>
chmod og-rwx <crontabfile>
```

```
chmod 644 /etc/passwd                 # Owner of the file has rw, while the group members and other users on the system only have r
chown root:root /etc/passwd
```

```
chmod 644 /etc/group
chown root:root /etc/group
```

```
chmod 600 /etc/shadow                 # Owner can rw
chown root:root /etc/shadow
```

```
chmod 600 /etc/gshadow
chown root:root /etc/gshadow
```

```
chown root:root /etc/grub.conf
chmod og-rwx /etc/grub.conf
```

Disable core dumps:
```
nano /etc/security/limits.conf
```

Add the following two lines:
```
* soft core 0
* hard core 0
```

Open the file:
```
nano /etc/sysctl.conf
```

Add the following three lines:
```
fs.suid_dumpable = 0
kernel.exec-shield = 1           # Turn on execshield
kernel.randomize_va_space = 2    # Address space layout randomization (ASLR)
```

****

<a name="startup"></a>

## Startup Services

View all services that run on startup:
```
sudo systemctl list-units --type=service #--state=active #--state=running
sudo service --status-all
```

Enable service to run on startup:
```
sudo systemctl enable SERVICENAME.service
```

See service status:
```
sudo systemctl status SERVICENAME.service
```

See open ports used by service
```
netstat -ltup | grep SERVICENAME
```

Stop service:
```
sudo systemctl disable SERVICENAME
sudo service SERVICENAME stop
```

****

<a name="network"></a>

## Network Parameters

Securing your Linux host network activities.

Open the CONFIG file:
```
nano /etc/sysctl.conf
```

EXAMPLE CONFIG FILE content:
```
net.ipv4.ip_forward = 0                                   # Disable the IP Forwarding
net.ipv4.conf.all.rp_filter = 1                           # Enable IP spoofing protection
net.ipv4.conf.all.accept_source_route = 0                 # Disable IP source routing
net.ipv4.icmp_echo_ignore_broadcasts = 1                  # Ignoring broadcasts request
net.ipv4.icmp_ignore_bogus_error_messages = 1             # Ignoring broadcasts request
net.ipv4.conf.all.log_martians = 1                        # Make sure spoofed packets get logged
net.ipv4.conf.all.send_redirects = 0                      # Disable the Send Packet Redirects
net.ipv4.conf.default.send_redirects = 0                  # Disable the Send Packet Redirects
net.ipv4.conf.all.accept_redirects = 0                    # Disable ICMP Redirect Acceptance
net.ipv4.conf.default.accept_redirects = 0                # Disable ICMP Redirect Acceptance
net.ipv4.icmp_ignore_bogus_error_responses = 1            # Enable Bad Error Message Protection
```

Check for open ports:
```
netstat -antp #-ltup
```

Avoid legacy communication services by removing them entirely:
```
sudo apt-get --purge remove xinetd nis yp-tools tftpd atftpd tftpd-hpa telnetd rsh-server rsh-redone-server
```


****

<a name="dns"></a>

## DNS over HTTPS

### Cloudflared

Download Cloudflared:
https://developers.cloudflare.com/1.1.1.1/dns-over-https/cloudflared-proxy

Check version:
```
cloudflared --version
```

Run the Proxy DNS (after verification that it works CTRL+C):
```
sudo cloudflared proxy-dns
```

Edit the CONFIG file:
```
sudo nano /usr/local/etc/cloudflared/config.yml
```

EXAMPLE of a CONFIG file:
```
proxy-dns: true
proxy-dns-port: 53
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
  #Uncomment following if you want to also want to use IPv6 for external DoH lookups
  #- https://[2606:4700:4700::1111]/dns-query
  #- https://[2606:4700:4700::1001]/dns-query
```

Verify that it is working:
```
dig +short @127.0.0.1 cloudflare.com AAAA
dig @127.0.0.1 google.com
dig +short @127.0.0.1 github.com AA
```

Install the service (Argo Tunnel client will run at boot):
```
sudo cloudflared service install
```

Change local DNS to localhost (127.0.0.1), as it is listening by default on:
```
localhost:53
```

Enable to run on Startup:
```
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

Check status:
```
sudo systemctl status cloudflared
```

Update Cloudflared:
```
sudo cloudflared update
sudo systemctl restart cloudflared
```

Uninstall Cloudflared:
```
sudo cloudflared service uninstall && rm -rf /usr/local/etc/cloudflared/config.yml && rm -rf /usr/local/etc/cloudflared
```

### dnscrypt-proxy

Download dnscrypt-proxy:
https://github.com/DNSCrypt/dnscrypt-proxy/wiki/installation

Uninstall dnscrypt-proxy (depends on the location of the folder, as well as your OS):
```
./dnscrypt-proxy -service stop

./dnscrypt-proxy -service uninstall
```

****

<a name="ufw"></a>

## Uncomplicated Firewall (UFW)

```
sudo apt install ufw
```

**CONFIG FILE:**
```
sudo nano /etc/default/ufw
```

Enable UFW:
```
sudo ufw enable
```

Check status:
```
sudo ufw status
```

Disable UFW:
```
sudo ufw disable
```

When applying changes to the CONFIG FILE:
```
sudo ufw reload
sudo service ufw restart
```

### Rules

Add DENY rule(s):
```
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw deny from IP_ADDRESS to any port 23 comment 'TELNET'
```

Add ALLOW rule(s):
```
sudo ufw allow ssh comment 'SSH'
sudo ufw allow PORT_NUMBER
sudo ufw allow dns comment 'DNS'
sudo ufw allow from IP_ADDRESS to any port 22 comment 'SSH'
sudo ufw allow from IP_ADDRESS to any port 53 comment 'DNS'
sudo ufw allow from IP_ADDRESS to any port 80 comment 'HTTP'
sudo ufw allow from IP_ADDRESS to any port 443 comment 'HTTPS'
```

Add [LIMIT](https://wiki.archlinux.org/index.php/Uncomplicated_Firewall#Rate_limiting_with_ufw) rule(s) (only IPv4 supported):
```
sudo ufw limit PORT_NUMBER/tcp comment 'Some comment here'
```

List all rules numbered:
```
sudo ufw status numbered
```

Delete rule number X:
```
sudo ufw delete NUMBER
```

Deactivate PING (go to section `# ok icmp codes for INPUT`):
```
sudo nano /etc/ufw/before.rules
```
Add the following line to `/etc/ufw/before.rules`:
```
-A ufw-before-input -p icmp --icmp-type echo-request -j DROP      # Reload ufw and reboot afterwards
```

### Display Network Socket

What's allowed into the server:
```
sudo ss -tupln
```

****

<a name="ssh"></a>

## SSH

Update SSH:
```
sudo apt install openssh-server
```

Create SSH Public Key:
```
ssh-keygen -t rsa -b 4096 -C COMMENT -f OUTPUT_KEYFILE    # maximum rsa is 16384 (takes longer)
```

Install Public Key; transfer the Public Key to the remote server:
```
ssh-copy-id USERNAME@LOCA_NETWORK_IP                                              # ON LINUX
scp ~/.ssh/SSH_PUBLIC_KEY_NAME.pub USERNAME@IP_ADDRESS:~/.ssh/authorized_keys     # ON MACOS (check the location of your .pub)
```

Check SSH status:
```
systemctl status ssh.service
```

Login with SSH:
```
ssh USERNAME@IP_ADDRESS -p PORT_NUMBER          # If different Port number has been set in the CONFIG file
```

Verify SHA256 host key fingerprint (seen when logging in for the first time; compare SHA256):
```
ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub    # SSH_PUBLIC_KEY_NAME.pub
```

**CONFIG FILE:**
```
sudo nano /etc/ssh/sshd_config
```

EXAMPLE CONFIG FILE content:
```
Port 2025                           # Port used for SSH connection
AddressFamily inet                  # Use IPv4 only (for IPv6 use `inet6`, and for both use `any`)
PermitRootLogin no                  # Root login disabled
AllowUsers USERNAME@IP_ADDRESS      # Allow specific users from specific IP Address
DenyUsers USERNAME                  # Deny specific users
AuthenticationMethods publickey     # Allow Public Key authentication (if 2FA is actived, then "publickey,password publickey,keyboard-interactive")
PubkeyAuthentication yes            # Enable Public Key authentication
PasswordAuthentication no           # Disable password authentication forcing use of keys
PermitEmptyPasswords no             # Empty passwords not permitted
Protocol 2                          # SSH protocol
X11Forwarding no                    # Disable remote application access
MaxAuthTries 3                      # Maximum SSH authentication attempts
ClientAliveInterval 300             # Disconnect idle sessions
ClientAliveCountMax 2               # Maximum live client sessions
UsePAM no                           # Pluggable Authentication Module (PAM) (if 2FA is actived, then "yes")
ChallengeResponseAuthentication no  # Related to PAM (if 2FA is actived, then "yes")
IgnoreRhosts yes                    # Disable Rhost authentication
HostbasedAuthentication no          # Disable host-based authentication
```

Extended CONFIG test:
```
sudo sshd -T
```

Change the permissions to the CONFIG file so that only root can edit:
```
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
```

When applying changes to the CONFIG FILE:
```
sudo systemctl restart sshd.service
sudo service sshd restart
```

Disable and stop SSH:
```
sudo systemctl disable sshd.service
sudo systemctl stop sshd.service
```

Enable and start SSH:
```
sudo systemctl start ssh.service
```

Restart SSH:
```
sudo service sshd reload
sudo systemctl restart sshd.service
sudo systemctl restart sshd
```

### 2FA

Install the PAM:
```
sudo apt-get install libpam-google-authenticator
```

Run the initialization app and answer questions (y, y, y, n, y):
```
google-authenticator
```

**CONFIG FILE**
```
sudo nano /etc/pam.d/sshd
```

Add to the CONFIG FILE:
```
# Standard Un*x authentication
#@include common-auth   # Comment this existing line

auth required pam_google_authenticator.so nullok
auth required pam_permit.so
```
_Note: In sshd_config change "ChallengeResponseAuthentication" to "yes", change "AuthenticationMethods" to "publickey,password publickey,keyboard-interactive" and restart SSH_

### SSH Audit
Source: https://github.com/arthepsy/ssh-audit

Run an Audit and review the report:
```
python ssh-audit.py TARGET_IP_ADDRESS
```

Remove current HosyKey entries in the SSH CONFIG file, and replace them with the following:
```
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
```

Change Default Ciphers and Algorithms by adding/replacing the following to the SSH CONFIG file:
```
KexAlgorithms curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
```

Re-run the Audit:
```
python ssh-audit.py TARGET_IP_ADDRESS
```

### Regenerate Moduli

Regenerate new Moduli in `/etc/ssh/moduli` (this process might take between several minutes to hours):
```
ssh-keygen -G moduli-2048.candidates -b 2048            # Candidate primes are generated
ssh-keygen -T moduli-2048 -f moduli-2048.candidates     # Candidate primes are tested for suitability
cp moduli-2048 /etc/ssh/moduli                          # Copy new moduli to specific folder
rm moduli-2048                                          # Remove moduli file in current direcotry
```
_Note: Restart SSH after changes are made._

### Fail2Ban

Install:
```
sudo apt-get install fail2ban
```

Copy CONFIG file as LOCAL jail:
```
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

**CONFIG FILE:**
```
sudo nano /etc/fail2ban/jail.local
```

Add the following lines to the LOCAL FILE content:
```
[DEFAULT]
ignoreip = 127.0.0.1/8

# Ban hosts for one hour
bantime = 3600

# Banning conditions
findtime = 600
maxretry = 3

# Override /etc/fail2ban/jail.d/00-firewalld.conf
banaction = iptables-multiport

[sshd]
enabled  = true
port    = ssh
logpath = %(sshd_log)s
```

When applying changes to the CONFIG FILE:
```
sudo service fail2ban restart
sudo systemctl restart fail2ban.service
```

Check Fail2Ban status:
```
sudo service fail2ban status
```

Check Fail2Ban jails status:
```
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

View recent logs:
```
sudo tail -F /var/log/fail2ban.log
```

Start Fail2Ban on startup:
```
sudo systemctl enable fail2ban.service
sudo systemctl enable fail2ban
```

### SSH File Transfer

Copy file from remote machine to local:
```
scp USERNAME@IPADDRESS:PATHNAME/SUBPATH/FILENAME.txt  myfile.txt
```

Copy file from local to remote machine:
```
scp myfile.txt USERNAME@IPADDRESS:PATHNAME/SUBPATH/FILENAME.txt
```

****

<a name="selinux"></a>

## SELinux
Security Enhanced Linux.

Install SELinux:
```
sudo apt install selinux selinux-utils selinux-basics auditd audispd-plugins
```

Verify SELinux status:
```
sudo sestatus
```

Put SELinux into enforcing mode:
```
sudo setenforce 1
```

Open the CONFIG file:
```
nano /etc/selinux/config
```

Add the following line:
```
SELINUX=enforcing
```

Ensure SSH access:
```
sudo semanage port -a -t ssh_port_t -p tcp 22
```


****

<a name="blacklist"></a>

## Disable USB Usage

Deny the usage of USB storage.

Open the CONFIG file:
```
nano /etc/modprobe.d/blacklist.conf
```

Add the following line:
```
blacklist usb_storage
```

Open the file:
```
nano /etc/rc.local
```

Add the following two lines:
```
modprobe -r usb_storage
exit 0
```

****

<a name="deborphan"></a>

## Uninstall Unused Packages

Install the package:
```
sudo apt install deborphan
```

Show all orphaned/unused packages:
```
deborphan
```

Remove all orphaned/unused packages:
```
sudo orphaner
```

****

<a name="encryption"></a>

Install GPG (if not already installed):
```
sudo apt-get install gpg
```

## Encrypt/Decrypt Files

### [GnuPG](https://gnupg.org/)
More info here: https://www.devdungeon.com/content/gpg-tutorial

Install GnuPG (if not already installed):
```
sudo apt-get install gpg
```

Create your Private GnuPG keys (using default asymmetric encryption type RSA):
```
gpg --gen-key
```
_Note: Fill out the information asked (Name and working Email), and use a strong password._

Generate your Public Key (MYPUBKEY.gpg):
```
gpg --armor --output MYPUBKEY.key --export YOUR-EMAIL@EMAIL.COM
```

Encrypt FILE.txt file with your Public Key (MYPUBKEY.gpg):
```
gpg --output FILE.txt.gpg --encrypt --recipient EMAIL@EMAIL.COM FILE.txt
```

Decrypt the encrypted FILE.txt file with your Private Key (enter your key password):
```
gpg --output FILE.txt --decrypt FILE.txt.gpg
```

List all Public Keys you have stored:
```
gpg --list-keys
```

List all your Private Keys:
```
gpg --list-secret-keys
```

Import external Public Key:
```
gpg --import PUBKEY-FROM-SOMEONE-ELSE.key
```

Search for external Public Keys on the MIT public key server:
```
gpg --keyserver pgp.mit.edu --search-keys EMAIL@EMAIL.com
```

Refresh your Public Key on the MIT public key server:
```
gpg --keyserver pgp.mit.edu --refresh-keys
```

Fingerprint of the Public Key (double check with owner of the Public Key):
```
gpg --fingerprint EMAIL@EMAIL.com
```

Sign external Public Key (only if trusted):
```
gpg --sign-key EMAIL@EMAIL.com
```

Send encrypted file:
```
gpg --encrypt --sign --armor -r EMAIL@EMAIL.COM  # File appended with ".asc", -r for the owner of the received external Public Key
```

****

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

****

<a name="randompw"></a>
## Create Random Passwords

Copy-paste into your terminal:
```
openssl rand -base64 200
```

_NOTE: change the value 200 to change the lenght of the password._

****

<a name="nginx"></a>

## NGINX

Create a folder for the server block (replace ```SERVER_BLOCK_NAME``` with your own domain):
```
sudo mkdir -p /var/www/SERVER_BLOCK_NAME/html
```

Assign ownership to user and change permissions:
```
sudo chown -R $USER:$USER /var/www/SERVER_BLOCK_NAME/html
sudo chown -R 755 /var/www/SERVER_BLOCK_NAME
```

Create the HTML file for the server block and add any HTML content you want to display:
```
sudo nano /var/www/SERVER_BLOCK_NAME/html/index.html
```

Open the server block CONFIG file:
```
sudo nano /etc/nginx/sites-available/SERVER_BLOCK_NAME
```

Add the following code in order to make your server block accessible via HTTP (port 80):
```
server {
        listen 80;
        listen [::]:80;

        root /var/www/SERVER_BLOCK_NAME/html;
        index index.html index.htm index.nginx-debian.html;

        server_name SERVER_BLOCK_NAME www.SERVER_BLOCK_NAME;

        location / {
                try_files $uri $uri/ =404;
        }

        # Robots.txt
        location = /robots.txt {
          add_header  Content-Type  text/plain;
          return 200 "User-agent: *\nDisallow: /\n";
        }
}
```

Enable the server block file by creating a link from it to the ```sites-enabled``` directory:
```
sudo ln -s /etc/nginx/sites-available/SERVER_BLOCK_NAME /etc/nginx/sites-enabled/SERVER_BLOCK_NAME
```

Open the NGINX CONFIG file:
```
sudo nano /etc/nginx/nginx.conf
```

To avoid a possible hash bucket memory problem that can arise from adding additional server names, uncomment the following line:
```
...
http {
    ...
    server_names_hash_bucket_size 64;
    ...
}
...
```

Validate the NGINX CONFIG file:
```
sudo nginx -t
```

Restart the NGINX process:
```
sudo systemctl restart nginx
```

****
