#!/usr/bin/env bash
set -euo pipefail

USER_NAME="johndaniher"
GROUP_NAME="johndaniher"

OPT_DIR="/opt/puter"
SRC_DIR="/home/${USER_NAME}/Documents/GitHub/PUTER/puter_interface/build/linux/arm64/release/bundle"
DST_DIR="${OPT_DIR}/interface"

SERVICE_SRC="/home/${USER_NAME}/Documents/GitHub/PUTER/installation/puter-interface.service"
USER_SERVICE_DIR="/home/${USER_NAME}/.config/systemd/user"
SERVICE_NAME="puter-interface.service"
SERVICE_DST="${USER_SERVICE_DIR}/${SERVICE_NAME}"

say() { echo -e "\n==> $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

echo "== PUTER: Deploy Interface =="
echo "Source:      $SRC_DIR"
echo "Destination: $DST_DIR"
echo "Service src: $SERVICE_SRC"
echo

# Validate
[[ -d "$SRC_DIR" ]] || die "Build folder not found: $SRC_DIR"
[[ -f "$SERVICE_SRC" ]] || die "Service file not found: $SERVICE_SRC"

# Stop user service if running
say "Stopping user service (if running)"
sudo -u "$USER_NAME" systemctl --user stop "$SERVICE_NAME" 2>/dev/null || true

# Ensure /opt exists
say "Ensuring ${OPT_DIR} exists"
sudo mkdir -p "$OPT_DIR"

# Deploy interface bundle
say "Deploying interface to ${DST_DIR}"
sudo rm -rf "$DST_DIR"
sudo cp -r "$SRC_DIR" "$DST_DIR"
sudo chown -R "${USER_NAME}:${GROUP_NAME}" "$DST_DIR"

# Ensure binary exists + executable
if [[ -f "${DST_DIR}/puter_interface" ]]; then
  sudo chmod +x "${DST_DIR}/puter_interface"
else
  echo "Contents of ${DST_DIR}:"
  ls -la "$DST_DIR"
  die "Expected binary not found: ${DST_DIR}/puter_interface"
fi

# Install user service file (from repo)
say "Installing user service to ${SERVICE_DST}"
sudo mkdir -p "$USER_SERVICE_DIR"
sudo cp "$SERVICE_SRC" "$SERVICE_DST"
sudo chown "${USER_NAME}:${GROUP_NAME}" "$SERVICE_DST"

# Enable linger so user services run at boot
say "Enabling linger for ${USER_NAME}"
sudo loginctl enable-linger "$USER_NAME" || true

# Reload + enable user service
say "Reloading user systemd"
systemctl --user daemon-reload

say "Enabling service"
systemctl --user enable "$SERVICE_NAME"

say "Starting service"
systemctl --user restart "$SERVICE_NAME"


say "Done."
echo
echo "Check status:"
echo "  sudo -u $USER_NAME systemctl --user status $SERVICE_NAME --no-pager -l"
echo "View logs:"
echo "  sudo -u $USER_NAME journalctl --user -u $SERVICE_NAME -f"
