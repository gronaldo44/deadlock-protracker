#!/usr/bin/env bash
set -euo pipefail

echo "=== Deadlock ability icon downloader (png + webp) ==="

BASE_HERO="https://assets.deadlock-api.com/v2/items/by-hero-id"

OUT_DIR="ability_icons"
PNG_DIR="${OUT_DIR}/png"
WEBP_DIR="${OUT_DIR}/webp"

mkdir -p "$PNG_DIR" "$WEBP_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "→ Fetching abilities (1–75) + extracting icon URLs..."
for hero_id in $(seq 1 75); do
  echo "  hero_id=$hero_id" >&2
  http --check-status GET "$BASE_HERO/$hero_id" \
  | jq -r '
      .[]
      | select(.class_name != null and .class_name != "")
      | select((.image // "") != "" or (.image_webp // "") != "")
      | select(.class_name | test("melee"; "i") | not)
      | [.class_name, (.image // ""), (.image_webp // "")] | @tsv
    ' >> "$TMP"
done

echo "→ Downloading..."
while IFS=$'\t' read -r class_name png_url webp_url; do
  safe_name="$(printf '%s' "$class_name" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9_-' '_')"

  if [[ -n "$png_url" ]]; then
    ext="${png_url##*.}"
    echo "  PNG  ${safe_name}.${ext}"
    curl -fsSL "$png_url" -o "${PNG_DIR}/${safe_name}.${ext}"
  fi

  if [[ -n "$webp_url" ]]; then
    echo "  WEBP ${safe_name}.webp"
    curl -fsSL "$webp_url" -o "${WEBP_DIR}/${safe_name}.webp"
  fi
done < "$TMP"

echo "=== Done ==="
echo "Saved to:"
echo "  • ${PNG_DIR}/"
echo "  • ${WEBP_DIR}/"

