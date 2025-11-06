#!/bin/bash
# Simple backup script for /var/www/html
set -euo pipefail

TIMESTAMP=$(date +"%F")
BACKUP_DIR="/var/backups"
BACKUP_FILE="web-backup-${TIMESTAMP}.tar.gz"

mkdir -p "${BACKUP_DIR}"
tar -czvf "${BACKUP_DIR}/${BACKUP_FILE}" /var/www/html
echo "Backup of /var/www/html complete: ${BACKUP_FILE}"

# Optional: add rotation (left as an exercise)
