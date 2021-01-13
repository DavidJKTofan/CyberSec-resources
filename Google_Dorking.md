# Google Dorking
Some interesting Google dorks.

## Definition
_"Google hacking, also named Google Dorking, is a hacker technique that uses Google Search and other Google applications to find security holes in the configuration and computer code that websites are using."_

More information:  https://www.exploit-db.com/google-hacking-database

***

Find URL/Website publishing date:
```
https://www.google.com/search?q=inurl:https://www.tercerob.com/3BValue&as_qdr=y15
inurl: URL_HERE &as_qdr=y15
```

Find Username Logs:
```
allintext:username filetype:log
```

Find open/publicly available Webcams:
```
inurl:/view.shtml
inurl:8080 "live view"
inurl:8081 "live view"
intitle:"webcamXP 5"
intitle:"EvoCam" inurl:"webcam.html"
intitle:”live view” intitle:axis
inurl:view/index.shtml
inurl:view/indexFrame.shtml
inurl:indexFrame.shtml Axis
inurl:/view.shtml spain
AXIS P5635-E MkII Network Camera
```
