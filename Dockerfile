FROM alpine:latest

RUN apk --no-cache add ca-certificates supervisor curl tar && \
    curl -sL -o /tmp/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip && \
    curl --silent 'https://api.github.com/repos/caddyserver/caddy/releases/latest' | grep 'browser_download_url' | grep 'linux_amd64.tar.gz' | awk '{print $2}' | xargs curl -sL -o /tmp/caddy.tar.gz --url && \
    mkdir -p /tmp/caddy && \
    tar -zxf /tmp/caddy.tar.gz -C /tmp/caddy && \
    mkdir -p /tmp/v2ray && \
    unzip -oq -d /tmp/v2ray /tmp/v2ray.zip && \
    mkdir -p /usr/bin/v2ray && \
    cp /tmp/v2ray/v2ray /usr/bin/v2ray && \
    cp /tmp/v2ray/v2ctl /usr/bin/v2ray && \
    cp /tmp/v2ray/geoip.dat /usr/bin/v2ray && \
    cp /tmp/v2ray/geosite.dat /usr/bin/v2ray &&\
    chmod +x /usr/bin/v2ray/v2ctl && \
    chmod +x /usr/bin/v2ray/v2ray && \
    cp /tmp/caddy/caddy /usr/bin && \
    chmod +x /usr/bin/caddy && \
    rm -rf /tmp/*

COPY index.html /usr/share/caddy/index.html
COPY supervisord.conf /etc/supervisord.conf
COPY config.json /etc/v2ray/config.json
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /usr/bin/start.sh

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data
ENV PATH /usr/bin/v2ray:$PATH

EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/start.sh"]
