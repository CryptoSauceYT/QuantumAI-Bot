#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# 🤖 QuantumAI Trading Bot - Installation
# Compatible: Ubuntu 18.04+, Debian 9+, all future versions
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
    # Try plugin first (modern way)
    if sudo apt-get update && sudo apt-get install -y docker-compose-plugin 2>/dev/null; then
        echo -e "${GREEN}✅ Docker Compose plugin installed${NC}"
    else
        # Fallback to standalone (older systems)
        sudo apt-get install -y docker-compose 2>/dev/null || {
            echo -e "${RED}❌ Could not install Docker Compose automatically${NC}"
            echo "Please install it manually: https://docs.docker.com/compose/install/"
            exit 1
        }
        echo -e "${GREEN}✅ Docker Compose standalone installed${NC}"
    fi
fi

# Create data directory
mkdir -p data

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
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ BOT INSTALLED AND RUNNING SUCCESSFULLY!                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
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
