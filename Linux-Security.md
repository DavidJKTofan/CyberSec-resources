## Update 

```
sudo apt update && sudo apt dist-upgrade && sudo apt full-upgrade && sudo apt autoremove -y && sudo apt autoclean && sudo apt clean
```

Reboot
```
sudo reboot
```

****

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
sudo service bluetooth stop
```

****

## Uncomplicated Firewall (UFW)

*CONFIG FILE:*
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
