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
if [ $VMESS_PATH ]; then
    VMESS_PATH=${VMESS_PATH//\\/\\\\}
    VMESS_PATH=${VMESS_PATH//\//\\\/}
    sed -i "s/PLACEHOLDER_VMESS_PATH/$VMESS_PATH/g" /etc/v2ray/config.json
    sed -i "s/PLACEHOLDER_VMESS_PATH/$VMESS_PATH/g" /etc/caddy/Caddyfile
fi
if [ $VMESS_PASSWD ]; then
    VMESS_PASSWD=${VMESS_PASSWD//\\/\\\\}
    VMESS_PASSWD=${VMESS_PASSWD//\//\\\/}
    sed -i "s/PLACEHOLDER_VMESS_PASSWD/$VMESS_PASSWD/g" /etc/v2ray/config.json
fi
if [ $SS_PATH ]; then
    SS_PATH=${SS_PATH//\\/\\\\}
    SS_PATH=${SS_PATH//\//\\\/}
    sed -i "s/PLACEHOLDER_SS_PATH/$SS_PATH/g" /etc/v2ray/config.json
    sed -i "s/PLACEHOLDER_SS_PATH/$SS_PATH/g" /etc/caddy/Caddyfile
fi
if [ $SS_PASSWD ]; then
    SS_PASSWD=${SS_PASSWD//\\/\\\\}
    SS_PASSWD=${SS_PASSWD//\//\\\/}
    sed -i "s/PLACEHOLDER_SS_PASSWD/$SS_PASSWD/g" /etc/v2ray/config.json
fi


# check your config if replace all placeholder
caddy_replace=$(cat /etc/caddy/Caddyfile | grep -E "PLACEHOLDER_DOMAIN|PLACEHOLDER_SS_PATH|PLACEHOLDER_VMESS_PATH")
if [ -n "$caddy_replace" ]; then
    echo "The caddy config not replace all, probably your environment config not set"
    exit 1
fi

v2ray_replace=$(cat /etc/v2ray/config.json | grep -E "PLACEHOLDER_SS_PATH|PLACEHOLDER_VMESS_PATH|PLACEHOLDER_SS_PASSWD|PLACEHOLDER_VMESS_PASSWD")
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
