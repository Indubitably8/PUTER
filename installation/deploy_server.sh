#!/usr/bin/env bash
set -euo pipefail

USER_NAME="johndaniher"
GROUP_NAME="johndaniher"

OPT_DIR="/opt/puter"
SRC_DIR="/home/${USER_NAME}/Documents/GitHub/PUTER/puter_server"
DST_DIR="${OPT_DIR}/server"

SERVICE_SRC="/home/${USER_NAME}/Documents/GitHub/PUTER/installation/puter-api.service"
SERVICE_NAME="puter-api.service"
SERVICE_DST="/etc/systemd/system/${SERVICE_NAME}"

# If you keep a dev venv in the repo, this script will (optionally) freeze it
DEV_VENV_DIR="${SRC_DIR}/venv"
FREEZE_REQUIREMENTS="true"   # set to "false" if you never want auto-freeze

say() { echo -e "\n==> $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

echo "== PUTER: Deploy Server =="
echo "Source:      $SRC_DIR"
echo "Destination: $DST_DIR"
echo "Service src: $SERVICE_SRC"
echo "Service dst: $SERVICE_DST"
echo

[[ -d "$SRC_DIR" ]] || die "Server folder not found: $SRC_DIR"
[[ -f "$SERVICE_SRC" ]] || die "Service file not found: $SERVICE_SRC"

# Update requirements.txt from dev venv
if [[ "${FREEZE_REQUIREMENTS}" == "true" ]]; then
  if [[ -x "${DEV_VENV_DIR}/bin/pip" ]]; then
    say "Freezing requirements.txt from dev venv: ${DEV_VENV_DIR}"
    "${DEV_VENV_DIR}/bin/pip" freeze > "${SRC_DIR}/requirements.txt"
    echo "Wrote: ${SRC_DIR}/requirements.txt"
  else
    echo "NOTE: Dev venv not found at ${DEV_VENV_DIR}. Skipping freeze."
    echo "      (Set FREEZE_REQUIREMENTS=false if you don't want this.)"
  fi
fi

# Stop service before modifying files
say "Stopping ${SERVICE_NAME} (if running)"
sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true

# Ensure /opt exists
say "Ensuring ${OPT_DIR} exists"
sudo mkdir -p "$OPT_DIR"

# Deploy server code
say "Deploying server to ${DST_DIR}"
sudo rm -rf "$DST_DIR"
sudo cp -r "$SRC_DIR" "$DST_DIR"
sudo chown -R "${USER_NAME}:${GROUP_NAME}" "$DST_DIR"

# Always rebuild venv to prevent path contamination
say "Rebuilding virtual environment in ${DST_DIR}"
rm -rf "${DST_DIR}/venv"
python3 -m venv "${DST_DIR}/venv"

# Upgrade pip
"${DST_DIR}/venv/bin/python" -m pip install --upgrade pip

# Install dependencies from requirements.txt
if [[ -f "${DST_DIR}/requirements.txt" ]]; then
  say "Installing dependencies from requirements.txt"
  "${DST_DIR}/venv/bin/pip" install -r "${DST_DIR}/requirements.txt"
else
  die "requirements.txt not found in deployed server (${DST_DIR}/requirements.txt). Create it in the repo first."
fi

# Quick sanity check: ensure uvicorn is available
say "Sanity check: uvicorn present?"
if ! "${DST_DIR}/venv/bin/python" -m uvicorn --version >/dev/null 2>&1; then
  echo "WARN: uvicorn not installed via requirements.txt."
  echo "      Add 'uvicorn[standard]' to requirements.txt."
  exit 1
fi

# Install systemd service file
say "Installing systemd service"
sudo install -m 644 "$SERVICE_SRC" "$SERVICE_DST"

# Reload systemd
say "Reloading systemd"
sudo systemctl daemon-reload

# Enable on boot
say "Enabling ${SERVICE_NAME}"
sudo systemctl enable "$SERVICE_NAME"

# Start service
say "Starting ${SERVICE_NAME}"
sudo systemctl start "$SERVICE_NAME"

say "Done."
echo "Check status:"
echo "  sudo systemctl status $SERVICE_NAME --no-pager"
echo "View logs:"
echo "  journalctl -u $SERVICE_NAME -f"
