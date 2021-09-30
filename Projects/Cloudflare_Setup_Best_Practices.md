# Cloudflare

A brief guide on how to **set up a Cloudflare account** and **add a Zone (domain)**, as well as **Best Practices** on Security and Performance features.

_Disclaimer: This is for educational purposes only, and depending on the situation, some configurations or steps might differ, or change, or have different impacts._

***

# Table of Contents
[Full or CNAME Setup](#fullsetup)  

***
***

<a name="fullsetup"></a>

## Full Setup

Full Setup: https://dt-testing.cf/ 

Add A Record:
```
A	www	35.234.81.115	Auto	Proxied
```

## CNAME Setup

CNAME Setup: https://dt-cname.cf/ 

Add CNAME Record on Authoritative DNS:
```
staging    CNAME    TTL 3600    staging.dt-cname.cf.cdn.cloudflare.net
```

***

<a name="troubleshooting"></a>

## Troubleshooting

### Check DNS Propagation

Check A Record for a *Full Setup*: https://dnschecker.org/#A/staging.dt-cname.cf.cdn.cloudflare.net OR `curl -svo /dev/null/ http://staging.dt-cname.cf/ 2>&1 | grep 'HTTP'`

Check TXT record for a *CNAME Setup*: https://dnschecker.org/#TXT/CLOUDFLARE-VERIFY.dt-cname.cf


https://staging.dt-cname.cf/cdn-cgi/trace 

### Check Response

Check the Cloudflare Response:
```
curl -svo /dev/null/ https://staging.dt-cname.cf/ 
```
```
Server: cloudflare
```

### Check Origin Server Response

Check the Origin Response:
```
curl -svo /dev/null/ http://35.234.81.115/
```
```
Server: Apache/2.4.18 (Ubuntu) (bypasses Cloudflare)
```

### Check Nameservers

Check Nameservers:
```
dig +short NS dt-testing.cf
```

*** 

## Allow Cloudflare IPs

Allow Cloudflare IP Addresses:
https://support.cloudflare.com/hc/en-us/articles/201897700-Allowing-Cloudflare-IP-addresses 

Restoring original visitor IPs:
https://support.cloudflare.com/hc/en-us/articles/200170786-Restoring-original-visitor-IPs 

Display all current settings of the IP packet filter:
```
sudo iptables -L -nv
```

Input Cloudflare IP Addresses (See Screenshot)

***

## Log Retention

Log Retention is off by default. We only store logs for 72h.
https://developers.cloudflare.com/logs/get-started 
Activate via API.
https://developers.cloudflare.com/logs/logpull/enabling-log-retention 

Scan Open Ports on Origin Server:
https://pentest-tools.com/network-vulnerability-scanning/tcp-port-scanner-online-nmap# 

Turn on the WAF, and then try a PHP Code Injection Test:
```
curl -svo /dev/null/ "https://www.dt-cname.cf/file.php?cmd=echo(shell_exec(%22ls%20/etc/var%22))"
```
```
for i in {1..100}; do curl -svo /dev/null/ -H "exploit: true" "https://www.dt-cname.cf/file.php?cmd=echo(shell_exec(%22ls%20/etc/var%22))" 2>&1 | grep "< HTTP"; done;
```

Create a Rate Limiting Rule.

Try out the Rate Limiting:
```
for i in {1..200}; do curl -svo /dev/null/ -H "requestflood: true" "https://www.dt-cname.cf/" 2>&1 | grep "< HTTP"; done;
```
This shouldn’t impact any good & verified bots like Google, pingdom, etc.

Page Rules to cache everything.

Test the Website Performance:
https://www.webpagetest.org/ 

Custom Purge. (See screenshot)


***

Run DNS queries and check DNS records:
```
dig @1.1.1.1 https://staging.dt-cname.cf/
```

cURL is a command line tool used to transport data using the URL syntax:
```
curl -svo /dev/null/ https://staging.dt-cname.cf/
```

Use cURL option to check the origin response directly:
```
curl -svo /dev/null/ https://staging.dt-cname.cf/ --connect-to ::35.234.81.115
```

MTR/Traceroute is Network based command line tools used to measure performance/latency on a particular path to a given host/destination:
```
sudo mtr staging.dt-cname.cf
```

***

https://support.cloudflare.com/hc/en-us/articles/360029779472 

https://support.cloudflare.com/hc/en-us/articles/115003011431-Troubleshooting-Cloudflare-5XX-errors 

https://support.cloudflare.com/hc/en-us/articles/203118044-How-do-I-generate-a-HAR-file- 

***

Day 4 – 

DNSSEC 
https://dnsviz.net/d/staging.dt-testing.cf/dnssec/ 

======
======
======

GItHUB

https://shields.io/category/other 
https://github.com/pabloqc/pabloqc/blob/main/README.md 

***

## Domain Lookup

https://rdap.cloudflare.com/