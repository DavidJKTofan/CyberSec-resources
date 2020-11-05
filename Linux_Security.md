
***

# Table of Contents
[System Update](#update)  
[User Management](#users)  
[Permissions](#permissions)  
[Startup Services](#startup)  
[Network Parameters](#network)  
[Uncomplicated Firewall](#ufw)  
[SSH](#ssh)  
[SELinux](#selinux)  
[Disable USB Usage](#blacklist)  

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
net.ipv4.icmp_ignore_bogus_error_responses parameter = 1  # Enable Bad Error Message Protection
```

Check for open ports:
```
netstat -antp #-ltup
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

