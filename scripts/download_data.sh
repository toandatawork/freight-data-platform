#!/usr/bin/env bash
set -euo pipefail

DEST="${DEST_OVERRIDE:-$(cd "$(dirname "$0")/.." && pwd)/data/raw}"
mkdir -p "$DEST"

echo "Downloading dataset from Kaggle (no token required)..."
curl -L -o /tmp/logistics.zip \
  "https://www.kaggle.com/api/v1/datasets/download/yogape/logistics-operations-database"

unzip -oq /tmp/logistics.zip -d "$DEST"
rm /tmp/logistics.zip

echo ""
echo "Row count per file (excluding header):"
for f in "$DEST"/*.csv; do
  printf "  %-35s %s\n" "$(basename "$f")" "$(($(wc -l < "$f") - 1))"
done

echo ""
echo "Expected baseline: loads 85410 · trips 85410 · delivery_events 170820 · fuel_purchases 196442"