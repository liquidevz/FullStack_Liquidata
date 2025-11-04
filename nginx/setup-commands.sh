#!/bin/bash
# Copy configuration to Nginx sites-available
sudo cp liquidata.dev /etc/nginx/sites-available/

# Enable the site
sudo ln -s /etc/nginx/sites-available/liquidata.dev /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Configure firewall
sudo ufw allow 'Nginx Full'
sudo ufw allow 'OpenSSH'

# Restart Nginx
sudo systemctl restart nginx

# Setup SSL with Certbot
sudo certbot --nginx -d liquidata.dev -d www.liquidata.dev