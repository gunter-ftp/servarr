#!/bin/bash

# Media Server Docker Stack - Setup Script
# Run this script on your Synology NAS via SSH

set -e

echo "==================================="
echo "Media Server Stack Setup Script"
echo "==================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Creating directory structure...${NC}"

# Create torrent directories
mkdir -p /volume1/data/torrents/{movies,tv,music}

# Create media directories
mkdir -p /volume1/data/media/{movies,tv,music}

# Create appdata directories
mkdir -p /volume1/docker/appdata/{gluetun,qbittorrent,prowlarr,sonarr,radarr,bazarr,overseerr,stash,cleanuparr,huntarr}

echo -e "${GREEN}✓ Directories created${NC}"

echo ""
echo -e "${YELLOW}Step 2: Setting permissions...${NC}"

# Set ownership (change 'docker' if you used a different username)
chown -R docker:users /volume1/data /volume1/docker

# Set permissions
chmod -R a=,a+rX,u+w,g+w /volume1/data /volume1/docker

echo -e "${GREEN}✓ Permissions set${NC}"

echo ""
echo -e "${YELLOW}Step 3: Checking for Docker network...${NC}"

# Check if network exists
if docker network inspect media_network &>/dev/null; then
    echo -e "${GREEN}✓ Network 'media_network' already exists${NC}"
else
    echo "Creating Docker network..."
    docker network create media_network \
        --subnet 172.20.0.0/16 \
        --gateway 172.20.0.1
    echo -e "${GREEN}✓ Network created${NC}"
fi

echo ""
echo -e "${GREEN}==================================="
echo "Setup Complete!"
echo "===================================${NC}"
echo ""
echo "Next steps:"
echo "1. Copy docker-compose files to /volume1/docker/appdata/"
echo "2. Edit .env file with your configuration:"
echo "   - PUID and PGID (run 'id docker' to find)"
echo "   - NordVPN credentials"
echo "   - Cloudflare Tunnel token"
echo "   - Timezone"
echo "3. Navigate to /volume1/docker/appdata/"
echo "4. Run: docker-compose up -d"
echo ""
echo -e "${YELLOW}For detailed instructions, see README.md${NC}"
