# Nginx Letsencrypt Reverse Proxy

## Setup

- Clone this repository
- Generate htpasswd
- Start docker-compose
- Run `./setup.sh`
- Reload nginx config

## htpasswd

Run `(echo -n "<YOUR_USERNAME>"; echo -n ":"; openssl passwd -apr1) >> ./files/htpasswd` to add a user to the passwd file.

## `./setup.sh`

**Running `./setup.sh` will overwrite all configs for every given domain**

```
./setup.sh <email> <sub-domain>.<host>:<local port> [...]

    Domain and local port can be repeated

    Example: test@example.com ./setup.sh www.example.com:8080 www2.example.com:8090
```

## Reload Nginx config

Run `docker-compose exec nginx nginx -s reload` while server is running to reload the nginx configuration.

## Configuration

After running the `./setup.sh` you can edit the nginx config for every domain under `files/nginx/$DOMAIN.host.conf`. (Needs nginx reload to apply)

