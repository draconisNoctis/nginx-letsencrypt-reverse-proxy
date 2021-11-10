#!/bin/bash


help() {
    >&2 echo "$0 <email> <domain>:<local port> [...]"
    >&2 echo ""
    >&2 echo "    Domain and local port can be repeated"
    >&2 echo ""
    >&2 echo "    Example: $0 test@example.com www.example.com:8080 www2.example.com:8090"
}

createDomainConfig() {
    DOMAIN=$1
    PORT=$2
cat <<EOT > ./files/nginx/$DOMAIN.host.conf
server {
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;

    server_name ${DOMAIN};
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    
    location / {
        proxy_pass http://localhost:${PORT};
    }
}
EOT
}

if [ "$#" -lt 2 ]; then
    help;
    exit 1;
fi

EMAIL=$1;
shift;

for arg in "$@"; do
    PARTS=($(echo $arg | tr ":" "\n"))
    DOMAIN=${PARTS[0]};
    PORT=${PARTS[1]};

    createDomainConfig $DOMAIN $PORT

    docker run \
        --network host \
        -ti \
        --volume "$(pwd)/files/runtime/certbot/www:/var/www/certbot" \
        --volume "$(pwd)/files/runtime/certbot/certificates:/etc/letsencrypt" \
        certbot/certbot certonly \
        --webroot -w /var/www/certbot -v -n --agree-tos --force-renewal --email $EMAIL -d $DOMAIN
done

echo "Setting chmod of root-owned certbot certificate files"
sudo chmod -R 0777 $(pwd)/files/runtime/certbot/certificates