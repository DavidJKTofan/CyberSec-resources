# WORK IN PROGRESS...

# Cloudflare

A brief and general guide on how to **set up a Cloudflare account**, **add a Zone (domain)**, as well as some **Best Practices** on Security and Performance solutions, including some Admin best practices.

Check out [New to Cloudflare? Start here.](https://developers.cloudflare.com/fundamentals/get-started/) or the [Considerations for enhancing cyber-readiness](https://www.cloudflare.com/lp/cyberattackreadiness/) on Cloudflare.

_Disclaimer: This is for educational purposes only, and depending on the situation, some configurations or steps might differ, or change, or have different impacts. Review your own needs and requirements._

* * *

# Table of Contents

[Security Best Practices](#securitybestpractices)  
[Performance Best Practices](#performancebestpractices)  
[Administrative Best Practices](#adminbestpractices)  
[Common Questions](#commonquestions)  

* * * *

[Full or CNAME Setup](#fullsetup)  
[Troubleshooting](#troubleshooting)  
[Allow Cloudflare IPs](#allowips)  
[Log Retention](#logs)  
[Domain Lookup](#domainlookup)  

* * * *
* * * *

<a name="securitybestpractices"></a>

# Security Best Practices

Generally, a great starting point is the [secure your application Learning Path](https://developers.cloudflare.com/learning-paths/application-security/).

## Using Cloudflare Registrar

With Cloudflare's Registrar you benefit from automatic [WHOIS redaction](https://developers.cloudflare.com/registrar/get-started/whois-redaction/), and some Enterprise customers or high-profile domains also enjoy [Cloudflare Custom Domain Protection](https://developers.cloudflare.com/registrar/reference/custom-domain-protection/).

## Enable DNS Security

Enable [DNSSEC](https://developers.cloudflare.com/dns/additional-options/dnssec/) for [your DNS records](https://dash.cloudflare.com/?to=/:account/:zone/dns).

## Secure Edge Certificates

Set your [SSL/TLS encryption mode](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/) to at least Full.

Additionally, enable Always Use HTTPS, Automatic HTTPS Rewrites, HTTP Strict Transport Security (HSTS), including setting the Minimum TLS Version to TLS 1.1, and enable TLS 1.3 on the [SSL/TLS Dashboard Tab](https://dash.cloudflare.com/?to=/:account/:zone/ssl-tls/edge-certificates).

## Secure Origin IP Addresses

_Orange-Cloud (proxy) all DNS Records for HTTP(S) traffic from your origin._

How a **Grey-Clouded** record looks like (should return non-Cloudflare IPs):
```
dig greycloud.theburritobot.com @woz.ns.cloudflare.com +short
```

How an **Orange-Cloude** record looks like (should return Cloudflare IPs):
```
dig orangecloud.theburritobot.com @woz.ns.cloudflare.com +short
```

More information on [protect your origin server](https://developers.cloudflare.com/fundamentals/get-started/task-guides/origin-health/).

## Configure your Security Level selectively

On [**Page Rules**](https://dash.cloudflare.com/?to=/:account/:zone/rules), select the URL pattern and set the Security Level Setting to High. Or set the general Securty Level of your website on the [**Security Settings**](https://dash.cloudflare.com/?to=/:account/:zone/security/settings).

_Note:_ decrease the Security Level for non-sensitive paths or APIs to reduce false positives.

_Security Level settings are aligned with a threat scores that IP addresses acquire with malicious behavior on our network._ 

More information on threat score and Security Level on [Cloudflare's Support Page](https://support.cloudflare.com/hc/en-us/articles/200170056-Understanding-the-Cloudflare-Security-Level).

## Activate your Web Application Firewall (WAF) safely

You can manage your [Firewall Rules and Managed Rulesets](https://dash.cloudflare.com/?to=/:account/:zone/security/waf/) on the Dashboard or via API.

First, deploy the [Managed Rulesets](https://developers.cloudflare.com/waf/managed-rulesets/) like the **Cloudflare OWASP Core Ruleset** sensitivity to High with an action of Simulate, in order to log any false positives. Depending on your website and use case, you might want to adjust these settings later on. Additionally, deploy the **Cloudflare Managed Ruleset** for automatic protection against some of the most common Common Vulnerabilities and Exposures (CVEs) out there.

You might also want to check out the [Rate Limiting](https://developers.cloudflare.com/waf/rate-limiting-rules/) rules and set up some for your login pages, or the [IP Access rules](https://developers.cloudflare.com/waf/tools/ip-access-rules/).

## Optimize your DDoS protection

Check out the [DDoS Attack Protection Managed Rulesets](https://developers.cloudflare.com/ddos-protection/managed-rulesets/) and fine-tune your sensitivity.

Carefule when using [third-party services in front of Cloudflare](https://developers.cloudflare.com/ddos-protection/best-practices/third-party/).

## Review your Security Center

Enable and review the [Cloudflare Security Center](https://developers.cloudflare.com/security-center/) on your [Dashboard](https://dash.cloudflare.com/?to=/:account/security-center) for a better overview on your general security.

* * * *
* * * *

<a name="performancebestpractices"></a>

# Performance Best Practices

Generally, a great starting point is the [optimize site speed Learning Path](https://developers.cloudflare.com/learning-paths/optimize-site-speed/).

## One-Click Optimizations

Enable Auto Minify, Brotli compression, Early Hints, Enhanced HTTP/2 Prioritization, and _maybe_ Rocket Loader™ (forces JavaScript to be loaded asynchronously) and _maybe_ Mirage (mobile specific image optimization) on the [Speed Dashboard Tab](https://dash.cloudflare.com/?to=/:account/:zone/speed/optimization).

Additionally, enable [Argo Smart Routing](https://developers.cloudflare.com/argo-smart-routing/) (_add-on feature_) on the [Traffic Dashboard Tab](https://dash.cloudflare.com/?to=/:account/:zone/traffic).

Another big improvement is to enable the features HTTP/2, HTTP/2 to Origin, HTTP/3 (with QUIC), 0-RTT Connection Resumption, IPv6 Compatibility, and gRPC (mainly for APIs) on the [Network Dashboard Tab](https://dash.cloudflare.com/?to=/:account/:zone/network).

## Cache Everything

Enable **Cache Everything** for static HTML webpages on **Page Rules**.

Utilize conservative **TTLs (Time-to-Lives)** for content that changes occasionally.

Check the response header `CF-Cache-Status` to review [Cloudflare cache responses](https://developers.cloudflare.com/cache/about/default-cache-behavior/#cloudflare-cache-responses):
```
curl -I theburritobot.com | grep -Fi CF-Cache-Status
```

_Note: caching might happen after the first request, therefore, try the cURL command again._

## Optimize your Images

There are some [image solutions](https://developers.cloudflare.com/images/) which one can choose from.

Enable [Polish](https://dash.cloudflare.com/?to=/:account/:zone/speed/optimization) for image compression, or [Image Resizing](https://dash.cloudflare.com/?to=/:account/:zone/speed/optimization) to resize, adjust quality, (and more) and convert images to WebP format, on demand.

Alternatively, you can host your images on Cloudflare with [Cloudflare Images](https://dash.cloudflare.com/?to=/:account/images/images) and create variants.

## Live and On-Demand Video Streaming

Image optimization and performance is important, but what about video? [Cloudflare Stream](https://developers.cloudflare.com/stream/) _lets you or your end users upload, store, encode, and deliver live and on-demand video with one API, without configuring or maintaining infrastructure._

Go to the [Stream Dashboard Tab](https://dash.cloudflare.com/?to=/:account/stream/videos) to get started.

## Control your Third-Party Scripts

[Zaraz](https://dash.cloudflare.com/?to=/:account/:zone/zaraz) _gives you complete control over third-party tools and services for your website, and allows you to offload them to Cloudflare’s edge, improving the speed and security of your website._

You can find more information on the [Developer Docs](https://developers.cloudflare.com/zaraz/).

## Improving Search Engine Optimization (SEO)

Most Cloudflare features will already [improve your SEO](https://developers.cloudflare.com/fundamentals/get-started/task-guides/improve-seo/), but there are some things that one needs to review.

## WAN optimization technology

Accelerate your dynamic content with [**Railgun**](https://developers.cloudflare.com/railgun/), which compresses previously unreachable web objects.

* * * *
* * * *

<a name="adminbestpractices"></a>

# Admin Best Practices

## Securing user access

First and foremost, [verify your email address](https://developers.cloudflare.com/fundamentals/account-and-billing/account-setup/verify-email-address/) and enable [2FA](https://support.cloudflare.com/hc/en-us/articles/200167906) for your account.

Additionally, [review the roles](https://developers.cloudflare.com/fundamentals/account-and-billing/account-setup/manage-account-members/) of each user, and [manage active sessions](https://developers.cloudflare.com/fundamentals/account-and-billing/account-security/manage-active-sessions/).

Another important point is to periodically [review the audit logs](https://developers.cloudflare.com/fundamentals/account-and-billing/account-security/review-audit-logs/).

## Manage your brand by customizing Cloudflare pages

* **Domain-wide**: within the settings of each domain, you can go to the Customize application to change the default pages for each and every page we could potentially show your users.

* **Organization-wide**: if you have many domains within your CloudFlare account and would like to create Custom pages for all of them, you may do so within your Organization settings.

## Enforce 2-factor authentication across your entire organization

On the upper right hand corner, select **My Profile** > Authentication > Two-Factor Authentication.

Alternatively, go on **Manage Account** > Members > Member 2FA enforcement, in order to require all members to have two-factor authentication enabled.

* * * *
* * * *
* * * *

# Other Interesting / Useful Stuff

<a name="fullsetup"></a>

## Full Setup

Full Setup: use the setup wizard on Cloudflare's website when you register, follow the steps, and change your Domain's Nameservers.

Add A Record:
```
A	www	IP_ADDRESS	Auto	Proxied
```

Alternatively, one can do a [CNAME Setup](https://support.cloudflare.com/hc/en-us/articles/360020348832-Understanding-a-CNAME-Setup)

***

<a name="troubleshooting"></a>

## Troubleshooting

### MTU Size

Get the Maximum Transmission Unit (MTU) size on your device:
```
networksetup -getMTU en0
```

Do a Browser Integrity Check (BIC), which should return a 403 status code:
```
curl http://cf-testing.com --header "User-Agent: CloudFlare BIC Test" --verbose --silent 2>&1 | egrep -i "< HTTP|< Server:|< CF|<title>|signature"
```

### Check DNS Propagation & Response

Check A Record for a **Full Setup**: https://dnschecker.org/#A/staging.dt-cname.cf.cdn.cloudflare.net OR `curl -svo /dev/null/ http://staging.dt-cname.cf/ 2>&1 | grep 'HTTP'`

cURL is a command line tool used to transport data using the URL syntax:
```
curl -svo /dev/null/ https://staging.dt-cname.cf/
```

Use cURL option to check the origin response directly:
```
curl -svo /dev/null/ https://staging.dt-cname.cf/ --connect-to ::35.234.81.115
```

Check TXT record for a **CNAME Setup**: https://dnschecker.org/#TXT/CLOUDFLARE-VERIFY.dt-cname.cf

https://staging.dt-cname.cf/cdn-cgi/trace 


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
dig +short NS cf-testing.com
host -t NS cf-testing.com
```

Run DNS queries and check DNS records:
```
dig @1.1.1.1 https://staging.dt-cname.cf/
```

### traceroute / mtr

traceroute and tracert are computer network diagnostic commands for displaying possible routes (paths) and measuring transit delays of packets:
```
traceroute staging.dt-cname.cf
```

mtr is a network based command line tools used to measure performance/latency on a particular path to a given host/destination:
```
sudo mtr staging.dt-cname.cf
```

*** 

<a name="allowips"></a>

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

<a name="logs"></a>

## Log Retention

Log Retention is off by default.
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

*** 

## Create a Rate Limiting Rule.

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
***

https://support.cloudflare.com/hc/en-us/articles/360029779472 

https://support.cloudflare.com/hc/en-us/articles/115003011431-Troubleshooting-Cloudflare-5XX-errors 

https://support.cloudflare.com/hc/en-us/articles/203118044-How-do-I-generate-a-HAR-file- 

***

DNSSEC
https://dnsviz.net/d/staging.cf-testing.com/dnssec/ 

======
======
======

GitHub

https://shields.io/category/other 
https://github.com/pabloqc/pabloqc/blob/main/README.md 

***

<a name="domainlookup"></a>

## Domain Lookup

https://rdap.cloudflare.com/

* * * *
* * * *
* * * *

<a name="commonquestions"></a>

# Common Questions

## DNS

### Upload multiple DNS records

Upload multiple DNS records under the Advanced section with a TXT file in BIND format.

### CNAME Setup

A partial setup or CNAME setup allows you to route only the traffic you want through Cloudflare, allowing you to keep your Authoritative DNS.

### Orange Clouded Record

Orange Clouded DNS records return Cloudflare's anycast IPs, obfuscating origin IPs and allowing SSL/TLS termination at Cloudflare's Edge to apply security and performance features. Gray Clouded DNS records return the actual DNS record.

## SSL

### Use your own SSL Certificate

You can upload your own SSL Certificate and Private Keys into the Dashboard. Additionally, you can use [Data Localization](https://www.cloudflare.com/data-localization/) to comply with evolving regional data privacy requirements.

### Full SSL settings

On the SSL/TLS tab, it is recommended to select the "Full (strict)" or "Strict (SSL-Only Origin Pull)" option which validates that the certificate at your Origin Server is from a Certificate Authority, has not expired, and contains the hostname for the request coming from the visitor.

### Minimum TLS Version

The minimum TLS version by default is TLS 1.0. However, it is recommended to set the option to TLS 1.2 or above, like TLS 1.3.

### Universal SSL vs Dedicated SSL

You can choose if you want to use Universal SSL or Dedicated SSL, which will have your zone's domain name.

## Firewall

### Country Block

You can block any specific country, as well as apply Captcha Challenge or JavaScript Challenge, which presents a complex math problem to the browser and requires JS to be enabled in order to pass the challenge.

### Rate Limiting

Protects specific sites from brute force attacks.

### WAF Rules

Cloudflare offers a variety of WAF Rules, such as OWASP Top 10, managed Rulesets (maintained by Cloudflare's Security Engineers), and more. Additionally, you can write your own rules to i.e. block specific IPs or create more complex rules.

## Caching

### Purge Cached Items

Normally it takes less than 30 seconds for a cache purge across the entire Cloudflare network.

## Page Rules

## Traffic

## Speed

## Workers

## Multi-User Organization

## Analytics

## General

