# AdiBagsForever – WoW Forever (b0.1.10 r1, Kampf-Funktionstest)

**Maintainer:** Blackiron. **Based on:** AdiBags by Adirelle, later AdiBagsEx and further contributors. See `CREDITS.md`, `LICENSE`, and `LICENSES.md` for authorship and terms.

## Unterstützte Version

- **World of Warcraft: Forever 1.60.1** (Interface `16001`)
- Nur für Forever getestet, keine Freigabe für Retail oder Classic Era.

## Funktionen und getesteter Stand

- Kategorisierte Taschen mit Suche und Item-Interaktionen. Im Spiel erfolgreich getestet.
- Separate kategorisierte Begleitansicht für **Charakterbank-Tabs**; normale Blizzard-Bank bleibt sichtbar. Anzeige und einfache Ein-/Auslagerung per Nutzerbericht bestätigt.
- Minimap-Schaltfläche öffnet **nur die Einstellungen** (Links- und Rechtsklick).
- BoE, BoP und andere bislang ungetragene Ausrüstung werden getrennt geführt. Tragehistorie pro Item-GUID ist implementiert, **Ingame-Abnahmetest fehlt noch**.
- Einstellungen über `/adibagsforever`; lesende Diagnose `/abfbankdebug` am Bankier.

## Bekannte Einschränkungen dieser Version

- **Taschen als Gegenstand:** Drag-and-drop mit linker Maustaste in die Blizzard-Bank funktioniert im Test. Rechtsklick kann dagegen einen Ausrüstungsversuch auslösen (Meldung „Es gibt keinen Ausrüstungsplatz für diesen Gegenstand“). Für Taschen in der Bank bitte vorerst Drag-and-drop verwenden.
- Bank-Suche, Bank-Sortierung und Account-/Kriegsmeutenbank sind noch nicht umfassend getestet bzw. nicht vollständig portiert. Keine wertvollen Gegenstände für ungetestete Aktionen verwenden.
- BoE-/BoP-Tragehistorie und Profilpersistenz nach Neustart benötigen weitere Ingame-Tests.
- **Kampftest neu:** Ein sicherer Tastenhandler öffnet/schließt die bereits vorbereitete Taschenansicht im Kampf. Die Inhalte bleiben bis zum Kampfende eingefroren; neue/verschobene Items werden danach aktualisiert. Vor dem öffentlichen Update muss dieser Ablauf in WoW Forever getestet werden.
- Der Minimap-Button bleibt ausschließlich für Einstellungen. MBB-Integration ist ein separater offener Punkt.
- Die Bank-Ansicht ist eine **zusätzliche** Oberfläche; die originale Blizzard-Bank bleibt als Rückfallmöglichkeit sichtbar.

## Installation

Die ZIP-Datei enthält **genau zwei Verzeichnisse auf oberster Ebene**:

```
AdiBags_FE/            (Hauptaddon)
AdiBags_FE_Config/     (Einstellungen)
```

Beide Verzeichnisse direkt in `World of Warcraft\_forever_\Interface\AddOns\` entpacken. **Keinen Versions-/ZIP-Unterordner** erstellen. Alte Ordner sichern und ersetzen, bevor WoW neu gestartet wird. Bei Updates `WTF`/SavedVariables **nicht löschen**.

## Quellcode und Integrität

Alle Lua-/XML-Dateien liegen lesbar bei. Das SHA-256-Dateimanifest liegt unter `AdiBags_FE/AdiBagsForever_SHA256_MANIFEST.txt`; die Archiv-Prüfsumme wird separat als `.zip.sha256` bereitgestellt. Hashes beweisen Integrität im Vergleich zu einer vertrauenswürdigen Quelle, keine Urheberschaft.

Keine Werbung, kostenpflichtigen Funktionen oder automatische Spielhandlungen. Die jeweils geltenden Blizzard-Regeln bleiben maßgeblich.
