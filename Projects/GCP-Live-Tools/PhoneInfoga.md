# PhoneInfoga

_Information gathering & OSINT framework for phone numbers._

GitHub repo: https://github.com/sundowndev/phoneinfoga

## Use on GCP

1. Create a free GCP account.

2. Open the Google Cloud Console by clicking on the _terminal_ icon at the top right corner of the homepage.

3. Install the tool:
```
docker pull sundowndev/phoneinfoga:latest
```

4. Run:
```
docker run -it -p 8080:8080 -e NUMVERIFY_API_KEY=YOUR_KEY sundowndev/phoneinfoga serve -p 8080
```

_Note: replace `YOUR_KEY` with your own [Numverify](https://numverify.com/) API key. You will have to create an account on Numverify too._

