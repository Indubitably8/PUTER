#!/usr/bin/env bash
set -euo pipefail

# =========================
# PUTER: one-time machine setup
# =========================
# Run:
#   chmod +x setup_machine.sh
#   ./setup_machine.sh
#
# What it does:
#  - Creates /opt/puter
#  - Makes you the owner (so future deploys don't need chown every time)
#  - Ensures deploy scripts are executable
#
# Safe to re-run anytime.

USER_NAME="johndaniher"
GROUP_NAME="johndaniher"

OPT_DIR="/opt/puter"
DEPLOY_DIR="/home/${USER_NAME}/Documents/GitHub/PUTER/installation"

say() { echo -e "\n==> $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

# ---- Verify user exists ----
if ! id "${USER_NAME}" &>/dev/null; then
  die "User ${USER_NAME} does not exist on this system."
fi

# ---- Warn if running as wrong user ----
if [[ "$(id -un)" != "${USER_NAME}" ]]; then
  echo "WARNING: Running as $(id -un), expected ${USER_NAME}"
fi

# ---- Create /opt/puter ----
say "Creating ${OPT_DIR} and setting ownership"
sudo mkdir -p "${OPT_DIR}"
sudo chown -R "${USER_NAME}:${GROUP_NAME}" "${OPT_DIR}"

# Owner: read/write/enter
# Group: read/enter
sudo chmod -R u+rwX,g+rX "${OPT_DIR}"

# ---- Make deploy scripts executable ----
say "Ensuring deploy scripts are executable"

if [[ -d "${DEPLOY_DIR}" ]]; then
  shopt -s nullglob
  scripts=("${DEPLOY_DIR}"/*.sh)

  if (( ${#scripts[@]} )); then
    chmod +x "${scripts[@]}"
    echo "Made executable:"
    for s in "${scripts[@]}"; do
      echo "  - $(basename "$s")"
    done
  else
    echo "No .sh files found in ${DEPLOY_DIR}"
  fi

  shopt -u nullglob
else
  echo "NOTE: Deploy directory not found: ${DEPLOY_DIR}"
  echo "      Update DEPLOY_DIR in this script if needed."
fi

say "Setup complete."
echo "You can now run your deploy scripts normally."