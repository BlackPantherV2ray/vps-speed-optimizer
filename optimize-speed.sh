#!/bin/bash
# Direct runner proxy to optimize.sh
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$DIR/optimize.sh" ]; then
    bash "$DIR/optimize.sh" "$@"
else
    bash <(curl -fsSL https://raw.githubusercontent.com/BlackPantherV2ray/vps-speed-optimizer/main/optimize.sh) "$@"
fi
