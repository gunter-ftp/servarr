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

echo -e "${YELLOW}Step 1: Loading TUN kernel module for VPN...${NC}"

# Check if TUN module is loaded
if lsmod | grep -q "^tun"; then
    echo -e "${GREEN}✓ TUN module already loaded${NC}"
else
    echo "Loading TUN module..."
    modprobe tun
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ TUN module loaded${NC}"
    else
        echo -e "${RED}✗ Failed to load TUN module${NC}"
        exit 1
    fi
fi

# Create TUN device if it doesn't exist
if [ ! -c /dev/net/tun ]; then
    echo "Creating /dev/net/tun device..."
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 0666 /dev/net/tun
    echo -e "${GREEN}✓ TUN device created${NC}"
else
    echo -e "${GREEN}✓ TUN device exists${NC}"
fi

echo ""
echo -e "${YELLOW}Step 2: Creating directory structure...${NC}"

# Create torrent directories
mkdir -p /volume1/data/torrents/{movies,tv,music}

# Create media directories
mkdir -p /volume1/data/media/{movies,tv,music}

# Create appdata directories
mkdir -p /volume2/docker/appdata/{gluetun,qbittorrent,prowlarr,sonarr,radarr,bazarr,overseerr,stash,cleanuparr,huntarr}

# Create stash directories
mkdir -p /volume2/docker/appdata/stash/{metadata,cache,blobs,generated}

echo -e "${GREEN}✓ Directories created${NC}"

echo ""
echo -e "${YELLOW}Step 3: Setting permissions...${NC}"

# Set ownership (change 'docker' if you used a different username)
chown -R docker:users /volume1/data /volume2/docker

# Set permissions
chmod -R a=,a+rX,u+w,g+w /volume1/data /volume2/docker

echo -e "${GREEN}✓ Permissions set${NC}"

echo ""
echo -e "${YELLOW}Step 4: Checking for Docker network...${NC}"

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
echo "1. Edit .env file with your configuration"
echo "2. Run: docker-compose up -d"
echo ""
echo -e "${YELLOW}Note: TUN module may need to be reloaded after reboot${NC}"
echo -e "${YELLOW}To make TUN persistent, add '/sbin/modprobe tun' to a startup script${NC}"
echo ""
echo -e "${YELLOW}For detailed instructions, see README.md${NC}"
