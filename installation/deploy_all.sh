#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/deploy_interface.sh"
"${SCRIPT_DIR}/deploy_server.sh"

echo
echo "Restarting services (if they exist)..."
sudo systemctl restart puter-api.service 2>/dev/null || echo "NOTE: puter-api.service not restarted (missing?)"
sudo systemctl restart puter-interface.service 2>/dev/null || echo "NOTE: puter-interface.service not restarted (missing?)"

echo "OK: All deploy steps complete."
