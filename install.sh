#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# 🤖 QuantumAI Trading Bot - Installation
# ═══════════════════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   🤖 QuantumAI Trading Bot - Installation                    ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Docker not found, installing...${NC}"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo -e "${GREEN}✅ Docker installed${NC}"
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Docker Compose...${NC}"
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    echo -e "${GREEN}✅ Docker Compose installed${NC}"
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
    echo -e "${BLUE}  docker compose up -d${NC}"
    echo ""
    exit 0
fi

# Download latest image
echo -e "${BLUE}📥 Downloading latest version...${NC}"
docker compose pull

# Start the bot
echo -e "${BLUE}🚀 Starting the bot...${NC}"
docker compose up -d

# Wait for startup
sleep 5

# Check status
if docker compose ps | grep -q "running"; then
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ BOT INSTALLED AND RUNNING SUCCESSFULLY!                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "📋 Useful commands:"
    echo "   docker compose logs -f     # View logs"
    echo "   docker compose restart     # Restart"
    echo "   docker compose down        # Stop"
    echo "   docker compose pull && docker compose up -d  # Update"
    echo ""
else
    echo -e "${RED}❌ Startup error. Check logs:${NC}"
    echo "   docker compose logs"
fi
