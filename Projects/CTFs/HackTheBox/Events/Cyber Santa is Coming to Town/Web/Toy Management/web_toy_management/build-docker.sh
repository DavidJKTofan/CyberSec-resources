#!/bin/bash
docker rm -f web_toy_management
docker build -t web_toy_management . 
docker run --name=web_toy_management --rm -p1337:1337 -it web_toy_management
