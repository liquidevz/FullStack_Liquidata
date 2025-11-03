# Deployment Guide

## Local Development

1. **Start Docker Desktop**

2. **Run:**
```bash
docker compose up --build -d
```

3. **Access:**
- Frontend: http://localhost:3000
- Backend: http://localhost:5001/api

## Hostinger Deployment

### Method 1: Hostinger Docker Manager (Easiest)

1. **Push to GitHub:**
```bash
git add .
git commit -m "Deploy"
git push
```

2. **In Hostinger Panel:**
   - VPS → Docker Manager → New Application
   - Repository: `https://github.com/liquidevz/FullStack_Liquidata.git`
   - Docker Compose: `docker-compose.yml`

3. **Set Environment Variables in Hostinger:**
```
MONGO_PASSWORD=your_secure_password
JWT_SECRET=your_jwt_secret_32_chars_min
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
NODE_ENV=production
```

4. **Configure Domain:**
   - Docker Manager → Domains → Add Domain
   - Point to port 3000

### Method 2: SSH Manual Deploy

1. **SSH to VPS:**
```bash
ssh root@YOUR_VPS_IP
```

2. **Clone & Deploy:**
```bash
cd /var/www
git clone https://github.com/liquidevz/FullStack_Liquidata.git
cd FullStack_Liquidata

# Create .env
cat > .env << EOF
MONGO_PASSWORD=your_secure_password
JWT_SECRET=your_jwt_secret_32_chars
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
NODE_ENV=production
EOF

docker compose up -d --build
```

3. **Setup Nginx:**
```bash
apt install nginx certbot python3-certbot-nginx

cat > /etc/nginx/sites-available/liquidata << EOF
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /api/ {
        proxy_pass http://localhost:5001/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

ln -s /etc/nginx/sites-available/liquidata /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

# SSL
certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

## Commands

**View logs:**
```bash
docker compose logs -f
```

**Restart:**
```bash
docker compose restart
```

**Stop:**
```bash
docker compose down
```

**Update:**
```bash
git pull
docker compose up -d --build
```
