# Hostinger Docker Deployment Fix

## Problem
Hostinger Docker Manager can't find Dockerfiles because they're in subdirectories.

## Solution

### Option 1: Use Hostinger Docker Manager (Recommended)

1. **In Hostinger Panel:**
   - Go to VPS → Docker Manager
   - Click "New Application"
   - Select "GitHub Repository"
   - Enter: `https://github.com/liquidevz/FullStack_Liquidata.git`
   - **Important:** Change Docker Compose file to: `docker-compose.hostinger.yml`
   - Click Deploy

2. **Set Environment Variables:**
   - In Docker Manager, click your app → Environment
   - Add:
     ```
     MONGO_PASSWORD=your_secure_password
     JWT_SECRET=your_jwt_secret_min_32_chars
     NEXT_PUBLIC_API_URL=https://yourdomain.com/api
     ```

3. **Configure Domain:**
   - In Docker Manager → Domains
   - Add your domain
   - Point to port 3000 (frontend)

### Option 2: Manual SSH Deployment (Full Control)

1. **Ensure Dockerfiles are committed to GitHub:**
   ```bash
   git add liquidata/Dockerfile liquidata-backend/Dockerfile
   git commit -m "Add Dockerfiles"
   git push
   ```

2. **SSH into VPS:**
   ```bash
   ssh root@YOUR_VPS_IP
   ```

3. **Clone and Deploy:**
   ```bash
   cd /var/www
   git clone https://github.com/liquidevz/FullStack_Liquidata.git
   cd FullStack_Liquidata
   
   # Create .env file
   nano .env
   ```

4. **Add to .env:**
   ```env
   MONGO_USER=admin
   MONGO_PASSWORD=your_secure_password
   MONGODB_URI=mongodb://admin:your_secure_password@mongodb:27017/liquidata?authSource=admin
   JWT_SECRET=your_jwt_secret_minimum_32_chars
   NEXT_PUBLIC_API_URL=https://yourdomain.com/api
   ```

5. **Deploy:**
   ```bash
   docker-compose up -d --build
   ```

6. **Setup Nginx Reverse Proxy:**
   ```bash
   apt install nginx
   nano /etc/nginx/sites-available/liquidata
   ```

   Add:
   ```nginx
   server {
       listen 80;
       server_name yourdomain.com www.yourdomain.com;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }

       location /api/ {
           proxy_pass http://localhost:5001/api/;
           proxy_http_version 1.1;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

   Enable:
   ```bash
   ln -s /etc/nginx/sites-available/liquidata /etc/nginx/sites-enabled/
   nginx -t
   systemctl restart nginx
   ```

7. **Setup SSL:**
   ```bash
   apt install certbot python3-certbot-nginx
   certbot --nginx -d yourdomain.com -d www.yourdomain.com
   ```

## Verify Deployment

- Frontend: `http://YOUR_VPS_IP:3000`
- Backend: `http://YOUR_VPS_IP:5001/api/health`
- With domain: `https://yourdomain.com`

## Troubleshooting

**Check logs:**
```bash
docker logs liquidata-frontend
docker logs liquidata-backend
docker logs liquidata-mongodb
```

**Restart services:**
```bash
docker-compose restart
```

**Check if ports are open:**
```bash
netstat -tulpn | grep -E '3000|5001'
```
