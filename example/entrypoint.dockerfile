FROM alpine:3.16

RUN apk add --no-cache curl

ENTRYPOINT ["/usr/bin/curl", "ifconfig.me"]
# CMD ["/usr/bin/curl", "ifconfig.me"]
