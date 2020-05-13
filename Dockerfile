FROM golang:alpine as builder

WORKDIR /src

RUN apk add --no-cache git curl ca-certificates

RUN git clone -b master https://github.com/caddyserver/caddy.git --single-branch
RUN git clone -b master https://github.com/v2fly/v2ray-core.git v2ray --single-branch

WORKDIR /src/caddy/cmd/caddy
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -tags netgo -ldflags '-extldflags "-static" -s -w' -o /usr/bin/caddy

RUN mkdir -p /usr/bin/v2ray
WORKDIR /src/v2ray/main
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -tags netgo -ldflags '-extldflags "-static" -s -w' -o /usr/bin/v2ray/v2ray

WORKDIR /src/v2ray/infra/control/main
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -tags netgo -ldflags '-extldflags "-static" -s -w' -o /usr/bin/v2ray/v2ctl

# RUN curl -sL -o /usr/bin/v2ray/geosite.dat "https://github.com/v2ray/domain-list-community/raw/release/dlc.dat"
# RUN curl -sL -o /usr/bin/v2ray/geoip.dat "https://github.com/v2ray/geoip/raw/release/geoip.dat"
RUN curl -sL -o /usr/bin/v2ray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
RUN curl -sL -o /usr/bin/v2ray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat

FROM alpine:latest

RUN apk --no-cache add ca-certificates supervisor

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /usr/bin/v2ray/v2ray /usr/bin/v2ray/v2ray
COPY --from=builder /usr/bin/v2ray/v2ctl /usr/bin/v2ray/v2ctl
COPY --from=builder /usr/bin/v2ray/geoip.dat /usr/bin/v2ray/geoip.dat
COPY --from=builder /usr/bin/v2ray/geosite.dat /usr/bin/v2ray/geosite.dat

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
