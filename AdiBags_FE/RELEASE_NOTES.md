# AdiBagsForever v0.1.10 r1 – Combat bag controls (2026-11-13)

**Game:** World of Warcraft Forever 1.60.1 (interface `16001`)
**Release type:** Release (for the CurseForge uploader)
**Developer/Maintainer:** Blackiron

## What's new

- **Fixed backpack controls in combat.** The bag now opens/closes through the assigned bag key (normally **B**), the bag **X** button, the **Blizzard backpack icon**, and **ESC**.
- Fixed the initial bag position/size preparation so opening in combat shows the categorized bag instead of a frame that reports visible but is not rendered.
- Secure click handlers respect WoW's protected UI restrictions. Deferred item/button updates resume after combat.
- Improved recovery of combat key bindings after `/reload` and provided read-only diagnostics via `/abfcombatdebug`.
- Corrected the version label in the addon settings to show the actual addon version.

**In-game verification:** All four bag controls above were successfully tested on Forever with b0.1.10 r18. No Lua game logic changes were made when promoting that test source to this public version.

## Known limitations

- Right-clicking a bag item into the standard Blizzard bank can still trigger an equip attempt; use drag-and-drop.
- Merchant right-click selling was modified in the development series and has **not been fully confirmed across all item types**; be cautious with valuable items.
- Character-bank sorting/search, account/warband bank cases, and equipment-wear history are not comprehensively tested.
- Inventory slot layout/contents are intentionally not rebuilt in combat; updates catch up afterwards.

## Installation

The ZIP includes exactly `AdiBags_FE/` and `AdiBags_FE_Config/` at its root. Extract both to `_forever_/Interface/AddOns`, or install through CurseForge when the uploaded release is available. Preserve `WTF/SavedVariables`. Internal folder identifiers stay unchanged from the in-game-tested version.

## Licensing

GNU GPLv3 or later for the core addon. Original AdiBags authors and contributors remain credited; bundled libraries retain their own licenses. See `CREDITS.md`, `LICENSE`, and `LICENSES.md`.

---

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
