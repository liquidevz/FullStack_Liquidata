# Fix GitHub Repository for Hostinger

Your liquidata and liquidata-backend folders are git submodules, not regular folders. Hostinger can't access the Dockerfiles.

## Fix Steps:

### Option 1: Remove Submodules (Recommended)

```bash
cd C:\Clients\Liquidata_Website

# Remove submodule entries
git rm --cached liquidata liquidata-backend
git commit -m "Remove submodules"

# Delete .git folders inside subdirectories
rmdir /s /q liquidata\.git
rmdir /s /q liquidata-backend\.git

# Add as regular folders
git add liquidata/ liquidata-backend/
git commit -m "Add source code and Dockerfiles"
git push
```

### Option 2: Use Separate Repos

Create 3 separate repos:
1. Main repo with docker-compose.yml
2. Frontend repo (liquidata)
3. Backend repo (liquidata-backend)

Then use multi-repo docker-compose or deploy manually via SSH.

### Option 3: Manual SSH Deployment (Easiest Now)

Skip Hostinger Docker Manager and deploy via SSH:

```bash
# On your local machine
scp -r C:\Clients\Liquidata_Website root@YOUR_VPS_IP:/var/www/

# SSH to VPS
ssh root@YOUR_VPS_IP

# Deploy
cd /var/www/Liquidata_Website
chmod +x deploy-hostinger.sh
./deploy-hostinger.sh yourdomain.com your@email.com
```

This script will:
- Install Docker
- Build containers
- Setup Nginx
- Configure SSL
- Start everything

Access at: https://yourdomain.com
