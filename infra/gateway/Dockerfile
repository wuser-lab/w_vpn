FROM alpine:3.21
RUN apk add --no-cache wireguard-tools iptables ip6tables unbound curl
COPY entrypoint.sh /entrypoint.sh
COPY unbound.conf /etc/unbound/unbound.conf
ENTRYPOINT ["/entrypoint.sh"]

