# AdiBagsForever

Categorized inventory and character-bank addon for **World of Warcraft Forever 1.60.1** (interface `16001`).

**Current maintainer:** Blackiron. Based on AdiBags by Adirelle and AdiBagsEx by later contributors including Talyrius and elemstream. All original attributions and license notices are preserved.

## Versions and distribution

- **`main`** — source prepared for **v0.1.10 r1** (release package; CurseForge upload is a separate publishing step).
- **`develop`** — experimental `b0.1.10 r12` baseline; not the current stable candidate.
- **Release notes:** `AdiBags_FE/RELEASE_NOTES.md`
- **CurseForge:** https://www.curseforge.com/wow/addons/adibagsforever

## What changed in v0.1.10 r1

The categorized backpack now opens/closes in combat with the user's bag key (usually **B**), its **X** button, the standard **Blizzard backpack icon**, and **ESC**. All four were confirmed in game using the b0.1.10 r18 test. Version labels and pre-combat window preparation were corrected; protected UI work and bag refreshes are deferred until combat ends.

Other bank, merchant, and equipment-history edge cases remain subject to the limitations described in the release notes. This is **not** an assertion that every possible item interaction was tested.

## Installation

The release ZIP contains two required addon directories at its root:

- `AdiBags_FE/`
- `AdiBags_FE_Config/`

Copy both into `World of Warcraft/_forever_/Interface/AddOns/`. Do not create an extra ZIP/version folder. Keep the existing `WTF/SavedVariables` data. The internal addon directory/API names are unchanged to preserve the tested client setup and settings.

## License, authorship, and source

The core addon remains free software under **GPLv3 or later**, with bundled third-party licenses documented in `AdiBags_FE/LICENSES.md`. See `LICENSE`, `AdiBags_FE/LICENSE`, and `AdiBags_FE/CREDITS.md`. No ads, paid features, automated gameplay, or CI/paid build services.

The release ZIP contains full source code and a SHA-256 file manifest under `AdiBags_FE/AdiBagsForever_SHA256_MANIFEST.txt`.
