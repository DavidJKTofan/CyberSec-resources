# CHALLENGE DESCRIPTION

Some web developers wrote this fancy new app! It's really cool, isn't it?

***
***

1. Downloaded the attached ZIP file and extracted the content.

2. We get an Android Backup (AB) file: `file cat.ab`, which we decompress with:

```
( printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" ; tail -c +25 cat.ab ) |  tar xfvz -
```

3. This returns several folders, but the most interesting one is the `shared/0/Pictures` folder.

4. One of the images stands out, as it is not a cat, like the rest of the images. Zooming into that image, we will find the flag.