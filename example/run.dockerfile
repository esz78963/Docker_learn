FROM alpine:3.16

RUN apk update
RUN apk add nginx
RUN mkdir /run/nginx