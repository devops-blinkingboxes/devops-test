FROM nginx:latest
# afaict, this command results in "latest curl already installed" or similar
# so likely this is a no-op and in this case may be removed. Don't forget
# to check on this (you'll likely forget)
RUN apt-get update; apt-get install curl
COPY ./site-content/ /usr/share/nginx/html/