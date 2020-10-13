
***

# Table of Contents
[System Update](#update)  
[Permissions](#permissions)
[Startup Services](#startup)  
[Network Parameters](#network)
[Uncomplicated Firewall](#ufw)  
[SSH](#ssh)  
[User Management](#users)  
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

```
nano /etc/sysctl.conf
```

Add the following three lines:
```
fs.suid_dumpable = 0
kernel.exec-shield = 1
kernel.randomize_va_space = 2
```

****

<a name="startup"></a>

## Startup Services

View all services that run on startup:
```
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

Stop service:
```
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
net.ipv4.conf.all.send_redirects = 0                      # Disable the Send Packet Redirects
net.ipv4.conf.default.send_redirects = 0                  # Disable the Send Packet Redirects
net.ipv4.conf.all.accept_redirects = 0                    # Disable ICMP Redirect Acceptance
net.ipv4.conf.default.accept_redirects = 0                # Disable ICMP Redirect Acceptance
net.ipv4.icmp_ignore_bogus_error_responses parameter = 1  # Enable Bad Error Message Protection
```

Check for open ports:
```
netstat -antp
```

****

<a name="ufw"></a>

## Uncomplicated Firewall (UFW)

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

Add DENY rule:
```
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw deny from 15.15.15.51 to any port 22
```

Add ALLOW rule:
```
sudo ufw allow ssh
sudo ufw allow from 15.15.15.51 to any port 22
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
AllowUsers USERNAME                 # Only allow specific users
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

Change the permissions to the CONFIG file so that only root can edit:
```
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
```

When applying changes to the CONFIG FILE:
```
sudo service ssh restart
service sshd restart
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

**CONFIG FILE:**
```
sudo nano /etc/fail2ban/jail.local
```

EXAMPLE CONFIG FILE content:
```
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

Start Fail2Ban on startup:
```
sudo systemctl enable fail2ban.service
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

<a name="users"></a>

## User Management

Change user password:
```
psswd USERNAME
```

****

<a name="selinux"></a>

## SELinux

Security Enhanced Linux.

Open the CONFIG file:
```
nano /etc/selinux/config
```

Add the following line:
```
SELINUX=enforcing
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

