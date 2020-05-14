#!/bin/sh

# 1.custom caddy v2ray config base64 string
# create config string command: base64 filepath
if [ $V2RAY_BASE64 ]; then
    echo "you used custom v2ray config"
    echo $V2RAY_BASE64 | base64 -d > /etc/v2ray/config.json
fi
if [ $CADDY_BASE64 ]; then
    echo "you used custom caddy config"
    echo $CADDY_BASE64 | base64 -d > /etc/caddy/Caddyfile
fi
# deal with sed \ and /
if [ $DOMAIN ]; then
    DOMAIN=${DOMAIN//\\/\\\\}
    DOMAIN=${DOMAIN//\//\\\/}
    sed -i "s/PLACEHOLDER_DOMAIN/$DOMAIN/g" /etc/caddy/Caddyfile
fi
if [ $PATH_BASE ]; then
    VMESS_WS_PATH="${PATH_BASE}vm"
    SS_WS_PATH="${PATH_BASE}ss"
    VMESS_H2_PATH="${PATH_BASE}h2"
fi
if [ $PASSWD_ALL ]; then
    VMESS_WS_PASSWD=$PASSWD_ALL
    SS_WS_PASSWD=$PASSWD_ALL
    VMESS_H2_PASSWD=$PASSWD_ALL
fi
if [ $VMESS_WS_PATH ]; then
    VMESS_WS_PATH=${VMESS_WS_PATH//\\/\\\\}
    VMESS_WS_PATH=${VMESS_WS_PATH//\//\\\/}
    sed -i "s/PLACEHOLDER_VMESS_WS_PATH/$VMESS_WS_PATH/g" /etc/v2ray/config.json
    sed -i "s/PLACEHOLDER_VMESS_WS_PATH/$VMESS_WS_PATH/g" /etc/caddy/Caddyfile
fi
if [ $VMESS_WS_PASSWD ]; then
    VMESS_WS_PASSWD=${VMESS_WS_PASSWD//\\/\\\\}
    VMESS_WS_PASSWD=${VMESS_WS_PASSWD//\//\\\/}
    sed -i "s/PLACEHOLDER_VMESS_WS_PASSWD/$VMESS_WS_PASSWD/g" /etc/v2ray/config.json
fi
if [ $SS_WS_PATH ]; then
    SS_WS_PATH=${SS_WS_PATH//\\/\\\\}
    SS_WS_PATH=${SS_WS_PATH//\//\\\/}
    sed -i "s/PLACEHOLDER_SS_WS_PATH/$SS_WS_PATH/g" /etc/v2ray/config.json
    sed -i "s/PLACEHOLDER_SS_WS_PATH/$SS_WS_PATH/g" /etc/caddy/Caddyfile
fi
if [ $SS_WS_PASSWD ]; then
    SS_WS_PASSWD=${SS_WS_PASSWD//\\/\\\\}
    SS_WS_PASSWD=${SS_WS_PASSWD//\//\\\/}
    sed -i "s/PLACEHOLDER_SS_WS_PASSWD/$SS_WS_PASSWD/g" /etc/v2ray/config.json
fi
if [ $VMESS_H2_PATH ]; then
    VMESS_H2_PATH=${VMESS_H2_PATH//\\/\\\\}
    VMESS_H2_PATH=${VMESS_H2_PATH//\//\\\/}
    sed -i "s/PLACEHOLDER_VMESS_H2_PATH/$VMESS_H2_PATH/g" /etc/v2ray/config.json
    sed -i "s/PLACEHOLDER_VMESS_H2_PATH/$VMESS_H2_PATH/g" /etc/caddy/Caddyfile
fi
if [ $VMESS_H2_PASSWD ]; then
    VMESS_H2_PASSWD=${VMESS_H2_PASSWD//\\/\\\\}
    VMESS_H2_PASSWD=${VMESS_H2_PASSWD//\//\\\/}
    sed -i "s/PLACEHOLDER_VMESS_H2_PASSWD/$VMESS_H2_PASSWD/g" /etc/v2ray/config.json
fi

# check your config if replace all placeholder
caddy_replace=$(cat /etc/caddy/Caddyfile | grep -E "PLACEHOLDER_DOMAIN|PLACEHOLDER_VMESS_WS_PATH|PLACEHOLDER_SS_WS_PATH|PLACEHOLDER_VMESS_H2_PATH")
if [ -n "$caddy_replace" ]; then
    echo "The caddy config not replace all, probably your environment config not set"
    exit 1
fi

v2ray_replace=$(cat /etc/v2ray/config.json | grep -E "PLACEHOLDER_SS_WS_PATH|PLACEHOLDER_VMESS_H2_PATH|PLACEHOLDER_VMESS_WS_PATH|PLACEHOLDER_VMESS_WS_PASSWD|PLACEHOLDER_SS_WS_PASSWD|PLACEHOLDER_VMESS_H2_PASSWD")
if [ -n "$v2ray_replace" ]; then
    echo "The v2ray config not replace all, probably your environment config not set"
    exit 1
fi

# varify your config file
caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
if [ $? -ne 0 ]; then
    echo "The caddy file verify error, please check your config"
    exit 1
fi
v2ray -test -config /etc/v2ray/config.json
if [ $? -ne 0 ]; then
    echo "The v2ray config verify error, please check your config"
    exit 1
fi

# start run
/usr/bin/supervisord -c /etc/supervisord.conf
