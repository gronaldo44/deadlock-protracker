# Project Outline and Description:

https://docs.google.com/document/d/1oksx76JP8RAb4EHxrFCBLhbGqK16XP1FhybWazK4P6E/edit?usp=sharing

## Working with Docker

Once Docker Desktop is installed, run the following command in the root directory:

```
docker compose up
```

If port `5433` already taken, create a `.env` file in the root directory and set `POSTGRES_PORT` to a different number, such as `5432`.

`docker compose exec python manage.py migrate` must be run at the start to initialize Django's database inside of the container.

___

## Tracker Schema Reference

See backend/apps/tracker/models.py for exact information.

### Hero
- hero_id: Int (PK)
- name: Char
- icon_key: Char

### Ability
- ability_id: Int (PK)
- name: Char
- icon_key: Char
- hero_id: FK → Hero

### ShopItem
- item_id: Int (PK)
- name: Char
- icon_key: Char
- imbue: Bool
- type: Char
- cost: Int
- upgrades_into_id: FK → ShopItem

### Account
- account_id: Int (PK)
- username: Char

### Rank
- rank_id: Int (PK)
- name: Char
- icon_key: Char

### Match
- match_id: Int (PK)
- date: DateTime
- duration: Duration
- avg_rank_id: FK → Rank

### PlayerPerformance
- id: AutoField (PK)
- account_id: FK → Account
- match_id: FK → Match
- kills: Int
- deaths: Int
- assists: Int
- networth: Int
- team: Int
- is_win: Bool

### PlayerAbility
- id: AutoField (PK)
- account_id: FK → Account
- match_id: FK → Match
- ability_id: FK → Ability
- game_time: Int

### PlayerItem
- id: AutoField (PK)
- account_id: FK → Account
- match_id: FK → Match
- item_id: FK → ShopItem
- game_time: Int
- sold_time: Int
- is_upgrade: Bool
- imbued_ability_id: FK → Ability