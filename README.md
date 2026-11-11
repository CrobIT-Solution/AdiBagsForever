# AdiBagsForever

A categorized inventory and character-bank addon for **World of Warcraft Forever (1.60.1)**.

**Current maintainer:** Blackiron. The project is based on AdiBags by Adirelle and later AdiBagsEx contributions, including Talyrius and elemstream. The original notices are retained in the sources and in `AdiBags_FE/CREDITS.md`.

## Branches

- **`main`** — public CurseForge release `v0.1.9 r1` (reference source).
- **`develop`** — experimental `b0.1.10 r12` source, including combat-toggle diagnostics. **Not an approved release.**

## Installation

Install the [CurseForge release](https://www.curseforge.com/wow/addons/adibagsforever) or copy both addon directories into the WoW Forever `Interface/AddOns` folder:

- `AdiBags_FE/`
- `AdiBags_FE_Config/`

Both directories are required. Do not install a surrounding version-named folder. The `.toc` files must be directly inside their respective addon directories.

## Current development caveats

The combat bag opening/closing behavior, `/reload`, merchant/trade right-click actions, and some bank/equipment corner cases still require in-game verification. Do not consider the `develop` branch stable.

## License and attribution

The core addon is distributed under **GNU GPL v3 or later** (see `LICENSE` and `AdiBags_FE/LICENSE`). Bundled third-party libraries have their own notices and licenses, documented in `AdiBags_FE/LICENSES.md`; the LGPL 2.1 text for LibSharedMedia is included under `AdiBags_FE/libs/LibSharedMedia-3.0/`.

This is a modified continuation of upstream software, not a wholly original rewrite. Keep all upstream copyright headers and licenses when redistributing.

## Build / automation

No automatic builds, deployments, CI, or paid services are configured. Releases are supplied as complete ZIP archives containing both addon directories.
