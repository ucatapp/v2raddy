FROM alpine:latest
ARG CADDY_NAME=caddy_2.0.0_linux_amd64.tar.gz

COPY config /tmp/config

RUN apk update && \
    apk add ca-certificates supervisor curl tar && \
    curl -sL -o /tmp/v2ray.zip https://github.com/v2ray/v2ray-core/releases/latest/download/v2ray-linux-64.zip && \
    curl -sL -o /tmp/caddy.tar.gz https://github.com/caddyserver/caddy/releases/latest/download/$CADDY_NAME && \
    mkdir -p /tmp/caddy && \
    tar -zxf /tmp/caddy.tar.gz -C /tmp/caddy && \
    mkdir -p /tmp/v2ray && \
    unzip -oq -d /tmp/v2ray /tmp/v2ray.zip && \
    mkdir -p /usr/bin/v2ray && \
    cp /tmp/v2ray/v2ray /usr/bin/v2ray && \
    cp /tmp/v2ray/v2ctl /usr/bin/v2ray && \
    cp /tmp/v2ray/geoip.dat /usr/bin/v2ray && \
    cp /tmp/v2ray/geosite.dat /usr/bin/v2ray && \
    chmod +x /usr/bin/v2ray/v2ctl && \
    chmod +x /usr/bin/v2ray/v2ray && \
    cp /tmp/caddy/caddy /usr/bin && \
    chmod +x /usr/bin/caddy && \
    mkdir -p usr/share/caddy && \
    cp /tmp/config/index.html /usr/share/caddy/index.html && \
    cp /tmp/config/supervisord.conf /etc/supervisord.conf && \
    mkdir -p /etc/v2ray && \
    cp /tmp/config/config.json /etc/v2ray/config.json && \
    mkdir -p /etc/caddy && \
    cp /tmp/config/Caddyfile /etc/caddy/Caddyfile && \
    cp /tmp/config/start.sh /usr/bin/start.sh && \
    rm -rf /tmp/*

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data
ENV PATH /usr/bin/v2ray:$PATH

EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/start.sh"]
