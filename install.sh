#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# 🤖 QuantumAI Trading Bot - Installation
# Compatible: Ubuntu 18.04+, Debian 9+, all future versions
# Includes: Nginx reverse proxy with SSL
# ═══════════════════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════════════════
# CROSS-PLATFORM DOCKER COMPOSE FUNCTION
# Works with both "docker compose" (v2 plugin) and "docker-compose" (v1 standalone)
# ═══════════════════════════════════════════════════════════════════════════
docker_compose() {
    if docker compose version >/dev/null 2>&1; then
        docker compose "$@"
    elif command -v docker-compose >/dev/null 2>&1; then
        docker-compose "$@"
    else
        echo -e "${RED}❌ Neither 'docker compose' nor 'docker-compose' found!${NC}"
        return 1
    fi
}

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   🤖 QuantumAI Trading Bot - Installation                    ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Docker not found, installing...${NC}"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo -e "${GREEN}✅ Docker installed${NC}"
    echo -e "${YELLOW}⚠️  Please log out and log back in, then run this script again.${NC}"
    exit 0
fi

# Check if Docker Compose is available (either version)
if ! docker compose version >/dev/null 2>&1 && ! command -v docker-compose >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Installing Docker Compose...${NC}"
    if sudo apt-get update && sudo apt-get install -y docker-compose-plugin 2>/dev/null; then
        echo -e "${GREEN}✅ Docker Compose plugin installed${NC}"
    else
        sudo apt-get install -y docker-compose 2>/dev/null || {
            echo -e "${RED}❌ Could not install Docker Compose automatically${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ Docker Compose standalone installed${NC}"
    fi
fi

# Create data directory
mkdir -p data

# ═══════════════════════════════════════════════════════════════════════════
# NGINX + SSL SETUP
# ═══════════════════════════════════════════════════════════════════════════
setup_nginx_ssl() {
    echo -e "${BLUE}🔒 Setting up Nginx with SSL...${NC}"
    
    # Install nginx
    apt-get update -qq
    apt-get install -y nginx openssl >/dev/null 2>&1
    
    # Get server IP
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || curl -s --connect-timeout 5 icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')
    
    if [ -z "$SERVER_IP" ]; then
        echo -e "${YELLOW}⚠️  Could not detect server IP, using localhost${NC}"
        SERVER_IP="localhost"
    fi
    
    echo -e "${BLUE}   Server IP: $SERVER_IP${NC}"
    
    # Create SSL directory and certificate
    mkdir -p /etc/nginx/ssl
    
    if [ ! -f /etc/nginx/ssl/nginx.crt ] || [ ! -f /etc/nginx/ssl/nginx.key ]; then
        echo -e "${BLUE}   Generating SSL certificate...${NC}"
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout /etc/nginx/ssl/nginx.key \
            -out /etc/nginx/ssl/nginx.crt \
            -subj "/CN=$SERVER_IP" 2>/dev/null
    fi
    
    # Create nginx config
    cat > /etc/nginx/sites-available/tradingbot << EOF
server {
    listen 443 ssl;
    server_name $SERVER_IP;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}

server {
    listen 80;
    server_name $SERVER_IP;
    return 301 https://\$host\$request_uri;
}
EOF

    # Enable site
    ln -sf /etc/nginx/sites-available/tradingbot /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Test and restart nginx
    if nginx -t 2>/dev/null; then
        systemctl restart nginx
        systemctl enable nginx 2>/dev/null
        echo -e "${GREEN}✅ Nginx with SSL configured${NC}"
        echo -e "${GREEN}   Webhook URL: https://$SERVER_IP/api/v1/place_limit_order${NC}"
    else
        echo -e "${RED}❌ Nginx configuration error${NC}"
        nginx -t
    fi
}

# Check configuration
if grep -q "REPLACE_WITH" config/application.yaml; then
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: You must configure the bot before launching!${NC}"
    echo ""
    echo "1. Edit the file config/application.yaml"
    echo "2. Replace the following values:"
    echo "   - REPLACE_WITH_YOUR_UID        → Your Bitunix UID"
    echo "   - REPLACE_WITH_YOUR_API_KEY    → Your Bitunix API key"
    echo "   - REPLACE_WITH_YOUR_API_SECRET → Your Bitunix API secret"
    echo ""
    echo "Command to edit:"
    echo -e "${BLUE}  nano config/application.yaml${NC}"
    echo ""
    echo "Once configured, launch the bot with:"
    echo -e "${BLUE}  ./install.sh${NC}"
    echo ""
    exit 0
fi

# Setup Nginx with SSL (run as root)
if [ "$EUID" -eq 0 ]; then
    setup_nginx_ssl
else
    echo -e "${YELLOW}⚠️  Run as root (sudo ./install.sh) to setup HTTPS automatically${NC}"
fi

# Download latest image
echo -e "${BLUE}📥 Downloading latest version...${NC}"
docker_compose pull

# Start the bot
echo -e "${BLUE}🚀 Starting the bot...${NC}"
docker_compose up -d

# Wait for startup
sleep 5

# Check status
if docker_compose ps 2>/dev/null | grep -q "running\|Up"; then
    # Get server IP for display
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ BOT INSTALLED AND RUNNING SUCCESSFULLY!                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "🔗 Webhook URL: ${BLUE}https://$SERVER_IP/api/v1/place_limit_order${NC}"
    echo ""
    echo "📋 Useful commands:"
    echo "   View logs:    docker compose logs -f  OR  docker-compose logs -f"
    echo "   Restart:      docker compose restart  OR  docker-compose restart"
    echo "   Stop:         docker compose down     OR  docker-compose down"
    echo "   Update:       ./install.sh"
    echo ""
else
    echo -e "${RED}❌ Startup error. Check logs:${NC}"
    docker_compose logs --tail 50
fi
