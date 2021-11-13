# WORK IN PROGRESS...
# TryHackMe: Wreath

Learn how to pivot through a network by compromising a public facing web machine and tunnelling your traffic to access other machines in Wreath's network. (Streak limitation only for non-subscribed users)

[YouTube Tutorial](https://youtube.com/playlist?list=PLsqUCyw0Jf9sMYXly0uuwfKMu34roGNwk)

* * * * * 
* * * * *

## Prep

Connect to the Network VPN server with openvpn:
```sudo openvpn CONFIG_FILE```

* * *

## Enumeration

```ping IP_ADDRESS```

How many of the first 15000 ports are open on the target?
```nmap -p 1-15000 -oA external IP_ADDRESS    # "-oA" to store scan results in normal, XML, and grepable formats```

What OS does Nmap think is running?
```nmap -p 22,80,443,10000 -sV -oA external-service IP_ADDRESS```

