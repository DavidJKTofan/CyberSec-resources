A brief overview on some packages and commands that help you secure your Linux operating system.

_Disclaimer: Some of the packages and/or commands may or may not work and/or vary in certain Linux distributions._

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

****

<a name="users"></a>

## User Management


Create a new user and add to sudo group:
```
sudo adduser USERNAME sudo
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

```
chown root:root /etc/anacrontab
chmod og-rwx /etc/anacrontab

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
chmod 644 /etc/passwd
chown root:root /etc/passwd
```

```
chmod 644 /etc/group
chown root:root /etc/group
```

```
chmod 600 /etc/shadow
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

Download Cloudflared:
https://developers.cloudflare.com/1.1.1.1/dns-over-https/cloudflared-proxy

Check version:
```
cloudflared --version
```

```
sudo cloudflared proxy-dns
```

Create folder and CONFIG file:
```
sudo mkdir /etc/cloudflared/
sudo nano /etc/cloudflared/config.yml
```

EXAMPLE of a CONFIG file:
```
proxy-dns: true
proxy-dns-port: 53
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
  #Uncomment following if you want to also want to use IPv6 for  external DOH lookups
  #- https://[2606:4700:4700::1111]/dns-query
  #- https://[2606:4700:4700::1001]/dns-query
```

Install the service:
```
sudo cloudflared service install
```

Verify that it is working:
```
dig +short @127.0.0.1 cloudflare.com AAAA
dig @127.0.0.1 google.com
```

Change local DNS to localhost, as it is listening by default on:
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
sudo ufw allow dns comment 'DNS'
sudo ufw allow from IP_ADDRESS to any port 22 comment 'SSH'
sudo ufw allow from IP_ADDRESS to any port 53 comment 'DNS'
sudo ufw allow from IP_ADDRESS to any port 80 comment 'HTTP'
sudo ufw allow from IP_ADDRESS to any port 443 comment 'HTTPS'
```

List all rules numbered:
```
sudo ufw status numbered
```

Delete rule number X:
```
sudo ufw delete NUMBER
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
ssh-keygen -t rsa -b 4096
```

Install Public Key:
```
ssh-copy-id USER@LOCA_NETWORK_IP
```

Check SSH status:
```
systemctl status ssh.service
```

**CONFIG FILE:**
```
sudo nano /etc/ssh/sshd_config
```

EXAMPLE CONFIG FILE content:
```
Port 2025                           # Port used for SSH connection
PermitRootLogin no                  # Root login disabled
AllowUsers USERNAME                 # Allow specific users
DenyUsers USERNAME                  # Deny specific users
AuthenticationMethods publickey     # Allow Public Key authentication
PubkeyAuthentication yes            # Enable Public Key authentication
PasswordAuthentication no           # Disable password authentication forcing use of keys
# PermitEmptyPasswords no           # Empty passwords not permitted
Protocol 2                          # SSH protocol
X11Forwarding no                    # Disable remote application access
MaxAuthTries 3                      # Maximum SSH authentication attempts
ClientAliveInterval 300             # Disconnect idle sessions
ClientAliveCountMax 2               # Maximum live client sessions
UsePAM no                           # Disable Pluggable Authentication Module (PAM)
ChallengeResponseAuthentication no  # Related to PAM
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

### Fail2Ban

Install:
```
apt-get install fail2ban
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
scp USER@IPADDRESS:PATHNAME/SUBPATH/FILENAME.txt  myfile.txt
```

Copy file from local to remote machine:
```
scp myfile.txt USER@IPADDRESS:PATHNAME/SUBPATH/FILENAME.txt
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

