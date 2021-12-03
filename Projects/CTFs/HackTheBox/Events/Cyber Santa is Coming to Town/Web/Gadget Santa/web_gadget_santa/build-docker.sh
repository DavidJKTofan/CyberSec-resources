#!/bin/bash
docker rm -f gadget_santa
docker build -t gadget_santa . && \
docker run --name=gadget_santa --rm -p1337:80 -it gadget_santa