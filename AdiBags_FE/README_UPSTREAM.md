# WoW Forever 0.1.6 – Anpassung (Alpha)

**Dies ist die von der Community angepasste Forever-Version (Interface 16001), nicht die unveränderte Retail-Ausgabe.**

- Das Addon sortiert das persönliche Inventar in Abschnitte. Die Nutzerregel ist **Variante A**: Ungetragene Ausrüstung wird nach ursprünglicher Bindungsart als BoE / BoP / Ungetragen geführt; genau die tatsächlich angelegte Gegenstandsinstanz wird über ihre GUID als **Equipment** gemerkt.
- Die Tragehistorie ist pro Charakter gespeichert. Sie erkennt keine zuvor getragenen und längst abgelegten Gegenstände rückwirkend.
- Die alte AdiBagsEx-Charakter-/Kriegsmeutenbank wurde für Forever bewusst **deaktiviert**. Die originale Blizzard-Bank bleibt bedienbar. Ebenso ist die inkompatible alte Ausrüstungsset-Verarbeitung vorläufig ausgeschaltet.
- Die Kompatibilität ist statisch und mit isolierten Lua-Tests geprüft, **nicht** im laufenden Forever-Client bestätigt.

**Einbau:** Nur `AdiBagsEx` und `AdiBagsEx_Config` nach `World of Warcraft\_forever_\Interface\AddOns` entpacken. Siehe `README-WOW-FOREVER.txt` auf Ebene des ZIP-Inhalts.

---

## Unveränderte Beschreibung der ursprünglichen Retail-Version (nicht alle Angaben gelten für Forever)

# AdiBagsEx

Enhanced version of Adirelle's popular bag addon with modern features for World of Warcraft 11.2.0+ (The War Within)

## Features

### ✨ New in AdiBagsEx
- **Warband Bank Support** - Full integration with WoW's new Warband Bank system
- **Dual Bank Interface** - Separate frames for Character Bank and Warband Bank
- **Smart Item Targeting** - Drag items to the correct bank type automatically
- **Toggle Controls** - W button to show/hide Warband Bank frame
- **Auto-Positioning** - Warband Bank appears aligned next to Character Bank

### 🎒 Core AdiBags Features
- **Item Filtering** - Automatic categorization and organization
- **Flexible Layout** - Customizable sections and columns
- **Search Function** - Find items quickly across all bags
- **Virtual Stacks** - Group identical items together
- **Quality Highlighting** - Visual indicators for item quality
- **Bank Integration** - Seamless bank and reagent bank support

## Installation

1. Download the latest release from CurseForge
2. Extract to your `World of Warcraft\_retail_\Interface\AddOns\` folder
3. Restart World of Warcraft
4. Type `/adibagsex` to configure settings

## Usage

### Basic Operation
- **Open Bags**: Press 'B' or click the bag icon
- **Bank Access**: Visit any bank - Character Bank opens automatically
- **Warband Bank**: Click the 'W' button when at a bank to toggle Warband Bank

### Warband Bank Features
- **Separate Interface**: Warband Bank has its own frame for clarity
- **Smart Targeting**: Items automatically go to the correct bank type
- **Visual Distinction**: Purple theme for Warband Bank items
- **Independent Positioning**: Move frames separately or together

### Configuration
- Type `/adibagsex` to open settings
- Configure filters, layout, and appearance
- Set up custom item categories
- Adjust positioning and sizing

## Compatibility

- **WoW Version**: 11.2.0+ (The War Within)
- **Game Types**: Retail only (Warband Banks are retail-specific)
- **Dependencies**: None required (some optional dependencies for enhanced features)

## Key Differences from Original AdiBags

1. **Enhanced Bank System**: Dual bank frames instead of sections
2. **Warband Integration**: Full support for account-wide banking
3. **Modern API Usage**: Updated for WoW 11.2.0+ compatibility
4. **Improved UX**: Better visual feedback and positioning

## Support

- **Issues**: Report bugs on the CurseForge page
- **Features**: Suggest improvements in the comments
- **Compatibility**: Tested with major bag-related addons

## Credits

- **Original Author**: Adirelle - Creator of the amazing AdiBags addon
- **AdiBagsEx**: Enhanced with Warband Bank support and modern features
- **Community**: Thanks to all users who provided feedback and suggestions

## License

GPL v3 - Same as original AdiBags

---

*AdiBagsEx brings the beloved AdiBags experience to modern WoW with full Warband Bank integration!*