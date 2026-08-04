#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

NGINX_DIR="/usr/syno/share/nginx"
BACKUP_DIR="/usr/syno/share/nginx_backup_$(date +%Y%m%d_%H%M%S)"

NEW_HTTP_PORT="8081"
NEW_HTTPS_PORT="8443"

# 1. Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo." >&2
  exit 1
fi

echo "==> Creating backup at: $BACKUP_DIR"
cp -a "$NGINX_DIR" "$BACKUP_DIR"

echo "==> Updating HTTP port (80 -> $NEW_HTTP_PORT)..."
grep -rl "listen 80\b" "$NGINX_DIR" | while read -r file; do
    echo "  Modifying $file"
    sed -i -E "s/listen ([^:]+:)?80\b/listen \1${NEW_HTTP_PORT}/g" "$file"
done

echo "==> Updating HTTPS port (443 -> $NEW_HTTPS_PORT)..."
grep -rl "listen 443\b" "$NGINX_DIR" | while read -r file; do
    echo "  Modifying $file"
    sed -i -E "s/listen ([^:]+:)?443\b/listen \1${NEW_HTTPS_PORT}/g" "$file"
done

echo "==> Restarting Synology Nginx service..."
synosystemctl restart nginx

echo "==> Port change complete! Synology DSM Nginx service restarted."
