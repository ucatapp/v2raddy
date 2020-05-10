### v2raddy
- support vmess+ws+tls
- support ss+v2ray-plugin and set mux=0

#### How to run
```bash
docker run --name v2ray_caddy \
-v /caddy/ssl:/data/caddy \
-v /caddy/html:/usr/share/caddy \
-p 80:80 -p 443:443 \
-e DOMAIN='www.example.com' \
-e VMESS_PATH='/vmesspath' \
-e SS_PATH='/sspath' \
-e VMESS_PASSWD='7c0136fd-2d7c-462b-b4be-ebd8df49276e' \
-e SS_PASSWD='04540dad-a32d-4baf-94ca-a3266d8bb978' \
-d ucatapp/v2raddy
```

