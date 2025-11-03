#!/bin/bash

DOMAIN=$1
EMAIL=$2

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Usage: ./setup-ssl.sh yourdomain.com your@email.com"
    exit 1
fi

echo "Setting up SSL for $DOMAIN..."

# Create temporary nginx config without SSL
cat > nginx-temp.conf << EOF
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 200 'OK';
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Start nginx with temp config
docker run -d --name temp-nginx \
    -p 80:80 \
    -v $(pwd)/nginx-temp.conf:/etc/nginx/nginx.conf:ro \
    -v $(pwd)/ssl:/etc/letsencrypt \
    -v certbot-data:/var/www/certbot \
    nginx:alpine

# Get SSL certificate
docker run --rm \
    -v $(pwd)/ssl:/etc/letsencrypt \
    -v certbot-data:/var/www/certbot \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN -d www.$DOMAIN

# Stop temp nginx
docker stop temp-nginx
docker rm temp-nginx

# Update nginx.conf with your domain
sed -i "s/yourdomain.com/$DOMAIN/g" nginx.conf

echo "SSL setup complete! Now run: docker-compose -f docker-compose.prod.yml up -d"
