#!/bin/bash

docker stop web
docker build -t webserver .
docker run -it --rm -d -p 8080:80 --name web webserver