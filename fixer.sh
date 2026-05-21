#!/bin/bash

# ============================================
# Pterodactyl Docker Fix - FUSE-overlayfs
# Fixed By NISSALOP2  🚀
# ============================================

set -e

echo "🔧 Starting Pterodactyl Docker Fix by NISSALOP2..."
echo "==========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root!${NC}"
   exit 1
fi

echo -e "${BLUE}📦 Installing fuse-overlayfs...${NC}"
apt update -y
apt remove containerd.io -y
apt install -y docker.io
apt install -y fuse-overlayfs

echo -e "${BLUE}⚙️ Configuring Docker daemon for fuse-overlayfs...${NC}"
# Backup existing daemon.json if it exists
if [ -f /etc/docker/daemon.json ]; then
    cp /etc/docker/daemon.json /etc/docker/daemon.json.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${YELLOW}📝 Backup created of existing daemon.json${NC}"
fi

# Write new configuration
cat > /etc/docker/daemon.json <<EOF
{
  "storage-driver": "fuse-overlayfs"
}
EOF

echo -e "${GREEN}✅ Docker daemon configured${NC}"

echo -e "${BLUE}🛑 Stopping Docker and Containerd services...${NC}"
systemctl stop docker
systemctl stop containerd

echo -e "${YELLOW}⚠️  Removing old Docker and Containerd data...${NC}"
rm -rf /var/lib/docker
rm -rf /var/lib/containerd

echo -e "${BLUE}🚀 Starting Containerd and Docker services...${NC}"
systemctl start containerd
systemctl start docker

# Wait a moment for services to fully start
sleep 3

# Verify Docker is working
echo -e "${BLUE}🔍 Verifying Docker storage driver...${NC}"
if docker info 2>/dev/null | grep -q "Storage Driver: fuse-overlayfs"; then
    echo -e "${GREEN}✅ Docker is now using fuse-overlayfs storage driver!${NC}"
else
    echo -e "${RED}⚠️  Warning: Docker may not be using fuse-overlayfs. Check with 'docker info'${NC}"
fi

# Restart Pterodactyl Wings if installed
if systemctl list-units --full -all | grep -q "wings.service"; then
    echo -e "${BLUE}🔄 Restarting Pterodactyl Wings...${NC}"
    systemctl restart wings
    echo -e "${GREEN}✅ Wings restarted${NC}"
fi

echo -e "${GREEN}===========================================================${NC}"
echo -e "${GREEN}🎉 FIXED PTERODACTYL PROBLEM 🎉${NC}"
echo -e "${GREEN}===========================================================${NC}"
echo -e "${BLUE}✨ Fixed By: NISSALOP2 ✨${NC}"
echo -e "${GREEN}===========================================================${NC}"
echo ""
echo -e "${YELLOW}📋 Summary:${NC}"
echo -e "  • fuse-overlayfs installed"
echo -e "  • Docker configured with fuse-overlayfs"
echo -e "  • Old Docker data cleaned"
echo -e "  • Services restarted successfully"
echo ""
echo -e "${GREEN}✅ PTERODACTYL PROBLEM SOLVED! 🦅${NC}"
echo -e "${BLUE}🏆 NISSALOP2  🏆${NC}"
