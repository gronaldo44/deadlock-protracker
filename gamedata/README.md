# Game Data

## Generate Static Tables of Game Data

Run `compute_tables.sh` to generate json data directly from Deadlock API that will populate the static tables in our database.

Note that returned shop items do not contain information on whether the item can be upgraded into a different item, nor what that item would be. This must be tracked manually or in some other way.

## Fetch Icons

Run `download_hero_icons.sh` to download available hero icons for each hero.

Icons are downloaded as both png and the smaller sized webp.

Note that icons for shop items may not be what we actually want as they are simplified, single color representations of the item, unlike the fully colored pictures used in the shop and player's inventory.

We probably want to redo this in python and not actually rely on this for direct ingestion of the static tables, just made this for testing purposes.
