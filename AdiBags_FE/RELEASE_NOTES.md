# AdiBagsForever v0.1.9 r1 – First public release (2026-11-09)

**Target:** World of Warcraft: Forever 1.60.1 (interface 16001)
**Release basis:** b0.1.9 r1 beta, which itself used the player-tested a0.1.8 r4 gameplay Lua source.

## Features

- Categorized inventory and item search.
- Separate categorized character-bank view while preserving the original Blizzard bank.
- Minimap button opens settings only.
- Bind-on-Equip (BoE), Bind-on-Pickup (BoP), unworn and previously equipped categorization, tracked per item GUID.
- Safe right-click handling for item use tested in-game with a consumable.

## Changes since b0.1.9 r1

- Promoted to **Release** distribution channel (the CurseForge file release type is set by the uploader).
- Unified the in-game titles (`AdiBags_Forever_v0.1.9`) and TOC versions (`0.1.9`).
- Updated release documentation and regenerated SHA-256 checksum manifest.
- **No changes to Lua game logic.**

## Known limitations / beta feedback still wanted

- A bag item dragged into the normal Blizzard bank works; right-click may try to equip it instead of depositing it. Use drag-and-drop for bags.
- Bank sort/search and account/warband-bank interactions have not been fully verified in game.
- BoE/BoP equipment history and combat-related interaction edge cases still need more in-game testing.
- CurseForge client installation of both included folders must be verified after publishing.

## Installation

The ZIP has two folders at its root: `AdiBags_FE` and `AdiBags_FE_Config`.
Extract both directly to `_forever_/Interface/AddOns`, or use CurseForge after the app install behavior has been verified. Do not remove your SavedVariables during upgrades.

## Licensing and authorship

Current maintainer: Blackiron. Based on AdiBags by Adirelle and AdiBagsEx, with prior contributions from Talyrius, elemstream, and others. See `CREDITS.md`, `LICENSE` (GPLv3 or later), `LICENSES.md`, and bundled library notices.
