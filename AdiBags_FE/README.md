# AdiBagsForever v0.1.10 r1 – WoW Forever

**Maintainer:** Blackiron. **Original developers:** Adirelle, Talyrius, elemstream and other contributors. Original license and copyright notices retained in source files and `CREDITS.md`.

## Kompatibilität

- **WoW Forever 1.60.1**, Interface `16001`
- Nicht für andere Clients getestet.

## Funktionen

- Kategorisierte Taschen, Suche, Kategorien und Filter
- Separate Charakterbank-Begleitansicht neben der originalen Blizzard-Bank
- BoE-/BoP-Kategorisierung und lokal erfasste Tragehistorie per Gegenstands-GUID
- Minimap-Button öffnet die Einstellungen
- **Kampfsteuerung korrigiert (ingame bestätigt):** B, X, Blizzard-Taschenbutton und ESC öffnen oder schließen die Taschenansicht auch im Kampf
- Geschützte Inventaraktualisierungen werden während des Kampfes zurückgestellt und danach wieder aufgenommen
- `/adibagsforever` für Einstellungen, `/abfcombatdebug` für lesende Kampfdiagnose

## Bekannte Einschränkungen

- Verschieben von Taschen in die Blizzard-Bank funktioniert per Drag-and-drop; Rechtsklick kann einen Ausrüstungsversuch auslösen.
- Händler-Rechtsklickpfade wurden verändert, sind aber für alle Itemtypen nicht abschließend im Spiel bestätigt. Wertvolle Gegenstände zunächst nicht für ungetestete Verkäufe verwenden.
- Bank-Suche/-Sortierung, Kriegsmeutenbank und Tragehistorie sind nicht umfassend getestet.
- Während des Kampfes bleibt die Anzeige auf dem vorbereiteten Stand; Gegenstandsdaten werden nach Kampfende aktualisiert.
- Die separate Charakterbankansicht ersetzt die native Blizzard-Bank nicht.

## Installation

Die Release-ZIP enthält genau diese beiden Addon-Verzeichnisse:

```text
AdiBags_FE/
AdiBags_FE_Config/
```

Beide direkt nach `World of Warcraft/_forever_/Interface/AddOns/` kopieren. Kein zusätzlicher Versionsordner. Bestehende Ordner vor dem Austausch sichern; `WTF/SavedVariables` **nicht löschen**. Alte interne Ordnernamen bleiben bewusst erhalten, damit die bestätigte Installation und Einstellungen kompatibel bleiben.

## Quellcode und Lizenz

Quellcode, GPLv3/Lizenztexte, ursprüngliche Autorenangaben und Bibliothekslizenzen sind enthalten. Die SHA-256-Dateiliste liegt unter `AdiBags_FE/AdiBagsForever_SHA256_MANIFEST.txt` (Manifestdatei selbst ausgenommen). Software ohne Werbung, Bezahlfunktionen oder Spielautomatisierung.
