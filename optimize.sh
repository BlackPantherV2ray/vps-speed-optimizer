#!/bin/bash
# ==============================================================================
#   🚀 VPS SPEED OPTIMIZER - ULTRA NETWORK & GOOGLE BBR BOOSTER
#   GitHub: https://github.com/BlackPantherV2ray/vps-speed-optimizer
#   Target OS: Ubuntu 20.04/22.04/24.04, Debian 10/11/12, CentOS/AlmaLinux/Rocky 8/9
# ==============================================================================

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}"
echo "=================================================================="
echo "         🚀 VPS SPEED OPTIMIZER - LINUX NETWORK ACCELERATOR      "
echo "        GitHub: github.com/BlackPantherV2ray/vps-speed-optimizer  "
echo "=================================================================="
echo -e "${NC}"

# 1. Check Root Privileges
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}[ERROR] This script must be run as root! Use: sudo bash $0${NC}"
    exit 1
fi

echo -e "${BLUE}[*] Checking System Specs & Linux Kernel...${NC}"
KERNEL_VER=$(uname -r)
echo -e "    -> Linux Kernel: ${GREEN}${KERNEL_VER}${NC}"

# 2. Backup existing configuration
echo -e "${BLUE}[*] Backing up /etc/sysctl.conf to /etc/sysctl.conf.bak...${NC}"
cp /etc/sysctl.conf /etc/sysctl.conf.bak 2>/dev/null || true

# 3. Clean any existing older optimization blocks from sysctl.conf
sed -i '/# === VPS SPEED OPTIMIZER ===/,/# === END VPS SPEED OPTIMIZER ===/d' /etc/sysctl.conf

# 4. Append Optimized Kernel & Network Settings
echo -e "${BLUE}[*] Enabling Google BBR, 32MB TCP Buffers & Fast Open...${NC}"
cat << 'EOF' >> /etc/sysctl.conf
# === VPS SPEED OPTIMIZER ===
# Google BBR Congestion Control & Fair Queuing (FQ)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# TCP Maximum Buffer Window (High Bandwidth / 4K Streaming / Fast Downloads)
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432

# Enable TCP Fast Open (Level 3: Client + Server) - Zero Handshake Delay
net.ipv4.tcp_fastopen = 3

# Disable Slow Start After Idle (Maintain Full Speed after browsing pause)
net.ipv4.tcp_slow_start_after_idle = 0

# Maximum Connection Backlog & Queuing for High Concurrent Users
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# Fast Recycling and Cleanup of Dead / Closed Sockets
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1

# Protection Against SYN Floods & Memory Leaks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 262144
# === END VPS SPEED OPTIMIZER ===
EOF

# Reload sysctl
sysctl -p >/dev/null 2>&1

# 5. Optimize File Descriptor Limits (Support up to 1,048,576 concurrent connections)
echo -e "${BLUE}[*] Increasing File Descriptor Limits (ulimit 1,048,576)...${NC}"
ulimit -n 1048576 2>/dev/null || true

sed -i '/soft nofile/d' /etc/security/limits.conf
sed -i '/hard nofile/d' /etc/security/limits.conf
cat << 'EOF' >> /etc/security/limits.conf
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF

# Update systemd default limits if systemd is present
if [ -f /etc/systemd/system.conf ]; then
    sed -i '/DefaultLimitNOFILE/d' /etc/systemd/system.conf
    echo "DefaultLimitNOFILE=1048576" >> /etc/systemd/system.conf
fi

# 6. Optimize DNS to Cloudflare (1.1.1.1) & Google (8.8.8.8)
echo -e "${BLUE}[*] Updating DNS Resolvers to Cloudflare (1.1.1.1) & Google (8.8.8.8)...${NC}"
if [ -f /etc/resolv.conf ]; then
    chattr -i /etc/resolv.conf 2>/dev/null || true
    cat << 'EOF' > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
fi

# 7. Verification & Status Report
echo ""
echo -e "${GREEN}${BOLD}=================================================================="
echo -e "          🎉 VPS NETWORK ACCELERATION COMPLETED! 🎉              "
echo -e "==================================================================${NC}"

BBR_STATUS=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
QDISC_STATUS=$(sysctl net.core.default_qdisc 2>/dev/null | awk '{print $3}')
LIMIT_STATUS=$(ulimit -n)

echo -e "  • ${BOLD}TCP Congestion Control:${NC}  ${GREEN}${BBR_STATUS}${NC} (Google BBR Active)"
echo -e "  • ${BOLD}Queue Discipline:${NC}        ${GREEN}${QDISC_STATUS}${NC} (Fair Queue Active)"
echo -e "  • ${BOLD}TCP Buffer Window:${NC}       ${GREEN}32 MB${NC} (Ultra High Bandwidth)"
echo -e "  • ${BOLD}TCP Fast Open:${NC}           ${GREEN}Level 3 (Zero Handshake Delay)${NC}"
echo -e "  • ${BOLD}Concurrent File Limits:${NC}  ${GREEN}${LIMIT_STATUS}${NC} Connections"
echo -e "  • ${BOLD}DNS Speed:${NC}               ${GREEN}Cloudflare (1.1.1.1) + Google (8.8.8.8)${NC}"

echo -e "${CYAN}=================================================================="
echo -e "  ✨ Speed Optimization Complete! Enjoy High Speed & Low Ping! ✨"
echo -e "==================================================================${NC}"
echo ""
