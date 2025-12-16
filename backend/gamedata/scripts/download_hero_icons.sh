#!/usr/bin/env bash
set -euo pipefail

echo "=== Deadlock hero icon downloader (png + webp) ==="

HERO_URL="https://assets.deadlock-api.com/v2/heroes"

OUT_DIR="hero_icons"
PNG_DIR="${OUT_DIR}/png"
WEBP_DIR="${OUT_DIR}/webp"

mkdir -p "$PNG_DIR" "$WEBP_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "→ Fetching heroes + extracting icon URLs..."
http --check-status GET "$HERO_URL" \
| jq -r '
  .[]
  | {
      class_name,
      png:  .images.icon_hero_card,
      webp: .images.icon_hero_card_webp
    }
  | select(.class_name != null and .class_name != "")
  | select((.png != null and .png != "") or (.webp != null and .webp != ""))
  | [.class_name, (.png // ""), (.webp // "")] | @tsv
' > "$TMP"

echo "→ Downloading..."
while IFS=$'\t' read -r class_name png_url webp_url; do
  safe_name="$(printf '%s' "$class_name" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9_-' '_')"

  if [[ -n "$png_url" ]]; then
    ext="${png_url##*.}"
    echo "  PNG  $safe_name.$ext"
    curl -fsSL "$png_url" -o "${PNG_DIR}/${safe_name}.${ext}"
  fi

  if [[ -n "$webp_url" ]]; then
    echo "  WEBP $safe_name.webp"
    curl -fsSL "$webp_url" -o "${WEBP_DIR}/${safe_name}.webp"
  fi
done < "$TMP"

echo "=== Done ==="
echo "Saved to:"
echo "  • ${PNG_DIR}/"
echo "  • ${WEBP_DIR}/"

