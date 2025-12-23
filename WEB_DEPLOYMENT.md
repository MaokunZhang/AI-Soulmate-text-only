# Web Deployment Guide

This guide explains how to deploy the Local NSFW Model Router as a web service securely.

## Table of Contents
1. [Security First](#security-first)
2. [Local Network Deployment](#local-network-deployment)
3. [Cloud Deployment Options](#cloud-deployment-options)
4. [Reverse Proxy Setup](#reverse-proxy-setup)
5. [HTTPS/SSL Configuration](#httpsssl-configuration)
6. [Authentication](#authentication)
7. [Monitoring and Logging](#monitoring-and-logging)

## Security First

⚠️ **CRITICAL**: Before deploying to the web:

1. **Never expose without authentication** - This application has no built-in auth
2. **Use HTTPS/TLS** - Encrypt all traffic
3. **Use a reverse proxy** - Nginx, Caddy, or Traefik
4. **Implement rate limiting** - Prevent abuse
5. **Keep credentials secure** - Use environment variables and secret management
6. **Regular updates** - Keep dependencies updated
7. **Monitor access logs** - Detect suspicious activity

## Local Network Deployment

### Option 1: Direct Deployment (LAN Only)

```bash
# Run on local network (accessible from other devices on your network)
streamlit run app.py --server.address 0.0.0.0 --server.port 8501

# Access from other devices: http://192.168.1.X:8501
```

**Security considerations**:
- Only accessible within your local network
- No authentication by default
- Consider firewall rules

### Option 2: Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f nsfw-router

# Stop
docker-compose down
```

## Cloud Deployment Options

### Option A: Virtual Private Server (VPS)

Suitable for: Hetzner, DigitalOcean, Linode, AWS EC2, Azure VM

**Requirements**:
- VPS with GPU (for optimal performance) or sufficient CPU
- Ubuntu 22.04 LTS or similar
- Minimum 8GB RAM (16GB+ recommended)
- 50GB+ storage

**Deployment steps**:

```bash
# 1. Connect to your VPS
ssh user@your-server-ip

# 2. Update system
sudo apt update && sudo apt upgrade -y

# 3. Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo apt install docker-compose -y

# 4. Clone repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# 5. Configure environment
cp .env.example .env
nano .env  # Add your API keys if using cloud models

# 6. Deploy with Docker Compose
docker-compose up -d

# 7. Check status
docker-compose ps
docker-compose logs -f
```

### Option B: Cloud Container Services

#### AWS ECS (Elastic Container Service)

```bash
# 1. Build and push to ECR
aws ecr create-repository --repository-name local-nsfw-router
docker build -t local-nsfw-router .
docker tag local-nsfw-router:latest YOUR_ECR_URI:latest
docker push YOUR_ECR_URI:latest

# 2. Create ECS task definition and service
# Use AWS Console or CLI to create task definition
# Set environment variables in task definition
```

#### Azure Container Instances

```bash
# 1. Login to Azure
az login

# 2. Create resource group
az group create --name nsfw-router-rg --location eastus

# 3. Create container instance
az container create \
  --resource-group nsfw-router-rg \
  --name nsfw-router \
  --image YOUR_REGISTRY/local-nsfw-router:latest \
  --dns-name-label nsfw-router \
  --ports 8501 \
  --environment-variables \
    OPENAI_API_KEY=$OPENAI_API_KEY \
    MONGO_URI=$MONGO_URI
```

#### Google Cloud Run

```bash
# 1. Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/PROJECT_ID/local-nsfw-router

# 2. Deploy to Cloud Run
gcloud run deploy local-nsfw-router \
  --image gcr.io/PROJECT_ID/local-nsfw-router \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated  # Change to authenticated in production
```

## Reverse Proxy Setup

### Nginx Configuration

```nginx
# /etc/nginx/sites-available/nsfw-router

server {
    listen 80;
    server_name your-domain.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL Configuration (see HTTPS section below)
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=nsfw_limit:10m rate=10r/m;
    limit_req zone=nsfw_limit burst=20 nodelay;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Proxy to Streamlit
    location / {
        proxy_pass http://localhost:8501;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }

    # WebSocket support for Streamlit
    location /_stcore/stream {
        proxy_pass http://localhost:8501/_stcore/stream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 86400;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/nsfw-router /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Caddy Configuration (Simpler Alternative)

```caddyfile
# /etc/caddy/Caddyfile

your-domain.com {
    reverse_proxy localhost:8501
    
    # Rate limiting
    rate_limit {
        zone dynamic {
            key {remote_host}
            window 1m
            limit 10
        }
    }
    
    # Security headers
    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
    }
}
```

## HTTPS/SSL Configuration

### Using Let's Encrypt (Free SSL)

#### With Certbot (Nginx)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is configured automatically
sudo certbot renew --dry-run
```

#### With Caddy (Automatic)
Caddy automatically obtains and renews SSL certificates. No additional configuration needed!

## Authentication

### Option 1: Basic Authentication (Nginx)

```bash
# Install htpasswd utility
sudo apt install apache2-utils -y

# Create password file
sudo htpasswd -c /etc/nginx/.htpasswd username

# Add to nginx config (inside server block)
# auth_basic "Restricted Access";
# auth_basic_user_file /etc/nginx/.htpasswd;
```

### Option 2: OAuth2 Proxy

```bash
# Deploy oauth2-proxy for Google/GitHub/etc authentication
docker run -d \
  --name oauth2-proxy \
  -p 4180:4180 \
  quay.io/oauth2-proxy/oauth2-proxy:latest \
  --provider=google \
  --client-id=YOUR_CLIENT_ID \
  --client-secret=YOUR_CLIENT_SECRET \
  --cookie-secret=RANDOM_SECRET \
  --email-domain=your-domain.com \
  --upstream=http://localhost:8501 \
  --http-address=0.0.0.0:4180
```

### Option 3: Cloudflare Access (Recommended)

1. Add your domain to Cloudflare
2. Enable Cloudflare Access
3. Create an Access Policy for your application
4. Users authenticate via Cloudflare before reaching your app

## Monitoring and Logging

### System Monitoring

```bash
# Install monitoring tools
sudo apt install htop iotop nethogs -y

# Monitor Docker containers
docker stats
docker-compose logs -f
```

### Application Monitoring

#### Prometheus + Grafana (Advanced)

Add to docker-compose.yml:
```yaml
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=your_password
```

### Log Management

```bash
# Centralized logging with ELK stack or Loki
# Or simple file-based logging

# Nginx access logs
tail -f /var/log/nginx/access.log

# Application logs
docker-compose logs -f nsfw-router

# System logs
journalctl -u docker -f
```

### Alerts

Set up monitoring alerts using:
- **Uptime Robot** - Free uptime monitoring
- **Better Uptime** - Status pages and alerts
- **Prometheus Alertmanager** - Advanced alerting
- **CloudWatch/Azure Monitor** - Cloud provider alerts

## Firewall Configuration

```bash
# Using UFW (Ubuntu)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Check status
sudo ufw status
```

## Performance Optimization

### 1. Caching
```nginx
# Add to nginx config
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g;

location / {
    proxy_cache my_cache;
    proxy_cache_valid 200 1h;
    # ... other proxy settings
}
```

### 2. Compression
```nginx
gzip on;
gzip_vary on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
```

### 3. Connection Pooling
Use connection pooling for database connections in your application.

## Backup and Disaster Recovery

```bash
# Backup script
#!/bin/bash
BACKUP_DIR="/backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup MongoDB
docker exec nsfw-mongodb mongodump --out /backup
docker cp nsfw-mongodb:/backup $BACKUP_DIR/mongodb

# Backup environment and configs
cp .env $BACKUP_DIR/
cp docker-compose.yml $BACKUP_DIR/

# Upload to S3 or backup service
# aws s3 sync $BACKUP_DIR s3://your-backup-bucket/
```

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   sudo lsof -i :8501
   sudo kill -9 PID
   ```

2. **Permission denied**
   ```bash
   sudo chown -R $USER:$USER /path/to/app
   ```

3. **Out of memory**
   - Increase swap space
   - Use smaller models
   - Add more RAM to your server

4. **SSL certificate issues**
   ```bash
   sudo certbot renew --force-renewal
   ```

## Cost Estimation

### Self-Hosted VPS
- Basic VPS (8GB RAM): $20-40/month
- GPU VPS (for faster inference): $100-300/month
- Domain name: $10-15/year
- SSL: Free (Let's Encrypt)

### Cloud Services
- AWS ECS: $30-200/month (depending on usage)
- Azure Container Instances: $40-150/month
- Google Cloud Run: Pay per request, ~$10-100/month

### API Costs (if using cloud models)
- OpenAI GPT-4: ~$0.03 per 1K tokens
- Azure OpenAI: Similar to OpenAI pricing
- xAI Grok: Varies by plan

## Best Practices Checklist

- [ ] Use HTTPS/TLS for all connections
- [ ] Implement authentication
- [ ] Set up rate limiting
- [ ] Configure firewall properly
- [ ] Enable monitoring and alerting
- [ ] Regular backups
- [ ] Keep software updated
- [ ] Use environment variables for secrets
- [ ] Implement logging
- [ ] Set up error tracking
- [ ] Test disaster recovery procedures
- [ ] Document your setup
- [ ] Monitor costs and usage

## Resources

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Streamlit Deployment Guide](https://docs.streamlit.io/knowledge-base/tutorials/deploy)

---

**⚠️ Legal Notice**: Ensure your deployment complies with:
- Local laws and regulations regarding adult content
- Terms of Service of your hosting provider
- Privacy laws (GDPR, CCPA, etc.)
- AI model licenses and usage terms
