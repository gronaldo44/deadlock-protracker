#!/usr/bin/env bash
set -euo pipefail

echo "=== Deadlock compute_tables ==="

############################
# 1. HEROES
############################

echo "→ Fetching hero.json"
http --check-status GET https://assets.deadlock-api.com/v2/heroes \
| jq '[.[] | {id, name, icon_key: .class_name}] | sort_by(.id)' \
> hero.json

############################
# 2. ABILITIES (1–75)
#    - flat list (no outer hero_id keys)
#    - id + name + icon_key (from class_name) + hero_id
#    - melee removed
############################

BASE_HERO="https://assets.deadlock-api.com/v2/items/by-hero-id"
TMP_ABILITIES="$(mktemp)"
trap 'rm -f "$TMP_ABILITIES"' EXIT

echo "→ Fetching ability.json"

for hero_id in $(seq 1 75); do
  echo "  hero_id=$hero_id" >&2
  http --check-status GET "$BASE_HERO/$hero_id" \
  | jq -c --argjson hid "$hero_id" '
      .[]
      | {
          id,
          name,
          icon_key: .class_name,
          hero_id: $hid
        }
      | select(.icon_key | test("melee"; "i") | not)
    ' >> "$TMP_ABILITIES"
done

jq -s '
  unique_by(.id)
  | sort_by(.hero_id, .id)
' "$TMP_ABILITIES" > ability.json

############################
# 3. ITEMS
############################

echo "→ Fetching item.json"

BASE_SLOT="https://assets.deadlock-api.com/v2/items/by-slot-type"

jq -s '
  flatten
  | map(select(type == "object" and has("id")))
  | unique_by(.id)
  | sort_by(.id)
' <(
  for slot in spirit vitality weapon; do
    echo "  slot=$slot" >&2
    http --check-status GET "$BASE_SLOT/$slot" \
    | jq '[.[] | {
        id,
        class_name,
        name,
        item_slot_type,
        cost,
        item_tier,
        imbue: has("imbue")
      }]'
  done
) > item.json

############################
# DONE
############################

echo "=== Done ==="
echo "Generated:"
echo "  • hero.json"
echo "  • ability.json"
echo "  • item.json"
