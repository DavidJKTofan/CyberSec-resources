## General Overview

Get all HTTP Response Headers:
```
curl -I -X GET https://www.cf-testing.com/
```

Get all HTTP Response Headers using HTTP/2:
```
curl -I --http2 https://www.cf-testing.com/
```

Get a specific HTTP Header:
```
curl -X GET -I https://www.cf-testing.com/ 2>&1 | grep cf-ray
curl -sv https://www.cf-testing.com/ 2>&1 | grep 'server:'
```

Reference: [HTTP request headers](https://developers.cloudflare.com/fundamentals/get-started/reference/http-request-headers/#cf-ray)

Get an overview:
```
curl -svo /dev/null https://cf-testing.com/ -w "\nContent Type: %{content_type} \
\nHTTP Code: %{http_code} \
\nHTTP Connect:%{http_connect} \
\nNumber Connects: %{num_connects} \
\nNumber Redirects: %{num_redirects} \
\nRedirect URL: %{redirect_url} \
\nSize Download: %{size_download} \
\nSize Upload: %{size_upload} \
\nSSL Verify: %{ssl_verify_result} \
\nTime Handshake: %{time_appconnect} \
\nTime Connect: %{time_connect} \
\nName Lookup Time: %{time_namelookup} \
\nTime Pretransfer: %{time_pretransfer} \
\nTime Redirect: %{time_redirect} \
\nTime Start Transfer: %{time_starttransfer} \
\nTime Total: %{time_total} \
\nEffective URL: %{url_effective}\n" 2>&1
```

Reference: [curl - the man page](https://curl.se/docs/manpage.html)

* * * 

## `/cdn-cgi/` Cloudflare Endpoint

Check User/Visitor information on visiting a Cloudflare website:
```
curl https://www.cf-testing.com/cdn-cgi/trace/
```

Reference: [`/cdn-cgi/` endpoint](https://developers.cloudflare.com/fundamentals/get-started/reference/cdn-cgi-endpoint/)

* * * 

## DNS

Check if website is available via specific Public DNS Resolver:
```
dig @1.1.1.1 cf-testing.com
```

Check TXT Records:
```
dig cf-testing.com txt
```

* * * 

## Nameservers (NS)

Check Nameservers:
```
host -t NS cf-testing.com
```

* * *

## Cache Status

Check Cache Status:
```
curl -I https://www.cf-testing.com/ | grep -Fi CF-Cache-Status
```

```
curl -I --silent --http2 -X GET https://www.cf-testing.com/ | grep -Fi CF-Cache-Status
```

* * * 

## Browser Integrity Check (BIC)

Testing Browser Integrity Check (BIC):
```
curl http://cf-testing.com --header "User-Agent: CloudFlare BIC Test" --verbose --silent 2>&1 | egrep -i "< HTTP|< Server:|< CF|<title>|signature"
```

Reference: [Understanding the Cloudflare Browser Integrity Check](https://support.cloudflare.com/hc/en-us/articles/200170086-Understanding-the-Cloudflare-Browser-Integrity-Check)

* * * 

## Mail Exchanger (MX) Records

Find MX Records:
```
dig -t mx cf-testing.com
```

Alternative:
```
nslookup -q=MX cf-testing.com
```

* * * 

## Transport Layer Security (TLS)

Check which TLS version is allowed:
```
curl https://www.cf-testing.com -svo /dev/null --tls-max 1.2
```

* * * 

## HTTP Version

Check if website supports HTTP/2:
```
curl -I --http2 -s https://cf-testing.com/ | grep HTTP
```

* * * 

## Hotlink Protection via ScrapeShield

Prevent other websites from linking to your image resources or abusing your bandwidth:
```
curl https://security.cf-testing.com/img/security-website-thumbnail.png -H 'Referer:referesite.com' -svo /dev/null 2>&1 --verbose | egrep -i "< HTTP|< CF|<title>|signature"
```

Allow (because it's located in the `hotlink-ok` directory):
```
curl https://security.cf-testing.com/img/hotlink-ok/security-hotlink-thumbnail.png -H 'Referer:referesite.com' -svo /dev/null --verbose --silent 2>&1 | egrep -i "< HTTP|< CF|<title>|signature"
```

Reference: [Understanding Cloudflare Hotlink Protection](https://support.cloudflare.com/hc/en-us/articles/200170026-Understanding-Cloudflare-Hotlink-Protection)

* * * 

## Web Application Firewall (WAF)

Testing WAF Rule `PHP - Code Injection`:
```
curl -svo /dev/null/ "https://www.cf-testing.com/file.php?cmd=echo(shell_exec(%22ls%20/etc/var%22))" 2>&1 | grep "< HTTP"
```

Testing WAF Rule `DotNetNuke - File Inclusion - CVE:CVE-2018-9126, CVE:CVE-2011-1892`:
```
curl -svo /dev/null/ -I "https://cf-testing.com/?url=file:///etc/passwd" 2>&1 | grep "< HTTP"
```

Testing WAF Rule `XSS, HTML Injection - Script Tag`:
```
curl -svo /dev/null -I "https://www.cf-testing.com?name=<script>alert(document.cookie)</script>" 2>&1 | grep "< HTTP"
```

Testing WAF Rule `SQLi - UNION in MSSQL`:
```
curl -svo /dev/null "https://www.cf-testing.com?user=-1+union+select+1,2,3,4,5,6,7,8,9,(SELECT+user_pass+FROM+wp_users+WHERE+ID=1)" 2>&1 | grep "< HTTP"
```

Reference: [Managed Rulesets](https://developers.cloudflare.com/waf/managed-rulesets/)

* * * 

## Rate Limiting

Testing Rate Limiting:
```
for i in {1..50}; do curl -svo /dev/null/ -H "requestflood: true" "https://www.cf-testing.com/" 2>&1 | grep "< HTTP"; done;
```

Reference: [Rate Limiting Rules](https://developers.cloudflare.com/waf/rate-limiting-rules/)

* * * 

## API Shield Discovery

Make random GET API calls:
```
for i in {1..10}; do curl -H "x-api-shield: DEMO" -H "Accept: application/json" -H "Content-Type: application/json" https://api.cf-testing.com/api/resources/$[ $RANDOM % 381 + 1 ]; sleep 2; done
```

```
for i in {1..10}; do curl -H "x-api-shield: DEMO" -H "Accept: application/json" -H "x-api-schema: validated" -H "Content-Type: application/json" https://api.cf-testing.com/api/resources/$[ $RANDOM % 381 + 1 ]; sleep 2; done
```

Reference: [API Discovery](https://developers.cloudflare.com/api-shield/security/api-discovery/)

## API Shield Schema Validation

```
openapi: 3.0.1
info:
  title: Serverless API on Resources
  description: World of Opportunities API through Cloudflare Workers
  version: '0.1'
  license:
    name: MIT
servers:
  - url: https://api.cf-testing.com/api
paths:
  /resources:
    get:
      summary: List all resources from the World of Opportunities database
      operationId: listResources
      tags:
        - resources
      parameters:
        - name: limit
          in: query
          description: How many items to return at one time (max 100)
          required: false
          schema:
            type: integer
            format: int32
      description: Auto generated using Swagger Inspector
      responses:
        '200':
          description: Auto generated using Swagger Inspector

  /resources/{id}:
    get:
      summary: Resource from the World of Opportunities database
      operationId: listResource
      tags:
        - resource
      description: Auto generated using Swagger Inspector
      parameters:
        - name: id
          in: path
          required: true
          description: The id of the resource to retrieve
          schema:
            type: integer
            format: int32
      responses:
        '200':
          description: Auto generated using Swagger Inspector
          content:
            application/json:
              schema:
                type: object
                properties:
                  main_cat1:
                    type: string
                  tag1:
                    type: string
                  main_cat2:
                    type: string
                  description:
                    type: string
                  id:
                    type: integer
                  title:
                    type: string
                  url:
                    type: string
                  tag2:
                    type: string
                  tag3:
                    type: string
              examples:
                '0':
                  value: >-
                    {"id":2,"title":"1 Million Free
                    Pictures","description":"Alternative source of free public
                    domain
                    pictures","url":"https://www.1millionfreepictures.com/","main_cat1":"CREATIVE","main_cat2":"","tag1":"PHOTO
                    STOCKS","tag2":"","tag3":""}
```

Reference: [Schema Validation](https://developers.cloudflare.com/api-shield/security/schema-validation/)

Reference: [Swagger Inspector – create Schema](https://inspector.swagger.io/builder)

* * * 

## SSL for SaaS

Verify SSL/TLS Certificates:
```
curl -svo /dev/null https://custom-hostname.cf-saas.com/ 2>&1 | grep -A6 'Server cert'
```
