# Hostinger Docker Deployment Guide

## Prerequisites
- Hostinger VPS with Docker installed
- Domain name pointed to your VPS IP
- SSH access to your VPS

## Step 1: Domain Configuration

### On Hostinger Control Panel:
1. Go to **Domains** → Select your domain
2. Click **DNS/Nameservers**
3. Add/Update A Records:
   ```
   Type: A
   Name: @
   Points to: YOUR_VPS_IP
   TTL: 14400

   Type: A
   Name: www
   Points to: YOUR_VPS_IP
   TTL: 14400
   ```
4. Wait 5-30 minutes for DNS propagation

## Step 2: VPS Setup

### Connect to VPS:
```bash
ssh root@YOUR_VPS_IP
```

### Install Docker (if not installed):
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### Install Docker Compose:
```bash
apt-get update
apt-get install docker-compose-plugin
```

## Step 3: Deploy Application

### Upload your project:
```bash
# On your local machine
scp -r c:\Clients\Liquidata_Website root@YOUR_VPS_IP:/var/www/
```

### On VPS:
```bash
cd /var/www/Liquidata_Website

# Create .env file with production values
nano .env
```

### .env Configuration:
```env
# MongoDB
MONGO_USER=admin
MONGO_PASSWORD=YOUR_SECURE_PASSWORD
MONGODB_URI=mongodb://admin:YOUR_SECURE_PASSWORD@mongodb:27017/liquidata?authSource=admin

# Backend
PORT=5001
NODE_ENV=production
JWT_SECRET=YOUR_JWT_SECRET_HERE

# Frontend
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
```

## Step 4: SSL Certificate Setup

```bash
# Make script executable
chmod +x setup-ssl.sh

# Run SSL setup
./setup-ssl.sh yourdomain.com your@email.com
```

## Step 5: Start Application

```bash
# Build and start all services
docker-compose -f docker-compose.prod.yml up -d --build

# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

## Step 6: Verify Deployment

1. Visit `https://yourdomain.com` - Should show frontend
2. Visit `https://yourdomain.com/api/health` - Should show backend status

## Management Commands

### View logs:
```bash
docker-compose -f docker-compose.prod.yml logs -f [service_name]
```

### Restart services:
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Stop services:
```bash
docker-compose -f docker-compose.prod.yml down
```

### Update application:
```bash
git pull  # or upload new files
docker-compose -f docker-compose.prod.yml up -d --build
```

### Backup MongoDB:
```bash
docker exec liquidata-mongodb mongodump --out /data/backup
docker cp liquidata-mongodb:/data/backup ./backup
```

## Firewall Configuration

```bash
# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp  # SSH
ufw enable
```

## Troubleshooting

### Check if ports are open:
```bash
netstat -tulpn | grep -E '80|443'
```

### Check DNS propagation:
```bash
nslookup yourdomain.com
```

### View container logs:
```bash
docker logs liquidata-frontend
docker logs liquidata-backend
docker logs liquidata-nginx
```

### Restart specific service:
```bash
docker-compose -f docker-compose.prod.yml restart frontend
```

## SSL Certificate Renewal

Certificates auto-renew via certbot container. Manual renewal:
```bash
docker-compose -f docker-compose.prod.yml run --rm certbot renew
docker-compose -f docker-compose.prod.yml restart nginx
```

## Performance Optimization

### Enable Docker logging limits:
Add to docker-compose.prod.yml for each service:
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Monitor resources:
```bash
docker stats
```
