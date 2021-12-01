# Toy Workshop

The work is going well on Santa's toy workshop but we lost contact with the manager in charge! We suspect the evil elves have taken over the workshop, can you talk to the worker elves and find out?

* * * * * *

## Step 1

Take a look at the files downloaded.

At first we can see a `HTB{f4k3_fl4g_f0r_t3st1ng}` flag in the `challenge/bot.js` file, but of course it is a _fake flag for testing_.

We can see on `build-docker.sh` and others that Port 1337 is supposed to be listened on.
A quick scan `nmap -Pn -p 1337 IP_ADDRESS` shows `1337/tcp filtered waste`.

## Step 2

