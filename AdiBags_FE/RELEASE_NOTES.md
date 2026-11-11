## b0.1.10 r11 - Diagnose /reload (Testversion)

- Kein neuer Combat-/X-/ESC-Handler; keine Änderungen an Inventar-, Bank- oder Händlerverhalten.
- Ein kleiner Fehler bei der Erfassung einer zweiten Tastenbelegung ist korrigiert.
- /abfcombatdebug zeigt tatsächliche Bindungen und Startzustand nach Reload an.
- Ingame-Test erforderlich; Veröffentlichung auf CurseForge noch nicht vorgesehen.

## b0.1.10 r10 – Reload-Wiederherstellung (Testversion)

- Rebind des bestehenden sicheren B-Kampfhandlers nach PLAYER_ENTERING_WORLD.
- Funktional sonst identisch zum bestaetigten r8-Stand.
- ESC, X und Leisten-Button im Kampf weiterhin offen.
- Ingame-Test nach /reload erforderlich. Keine CurseForge-Aktualisierung.

## b0.1.10 r8 – Regression-Rollback (Testversion)

- In r7 eingefuehrte sichere ESC-, X- und Taschenleisten-Eingriffe zurueckgenommen, da nach r7 laut Ingame-Test B im Kampf nicht mehr oeffnet.
- Nur das `core/Bags.lua`-Verhalten aus dem zuvor fuer B im Kampf bestaetigten r6-Stand wiederhergestellt.
- Kein Eingriff in Item-Buttons, Haendler, Spielerhandel, Bank, Minimap oder gespeicherte Einstellungen.
- ESC/X/Taschenleisten-Button im Kampf bleiben offen; diese Revision behebt nur den Rueckschritt bei B.
- Ingame-Verifikation von r8 weiterhin erforderlich; keine CurseForge-Veröffentlichung.

## b0.1.10 r7 – Kampftasche: Schliessen und Taschenleisten-Button (Test)

- Bereits funktionierende B-Kampftaste unveraendert.
- ESC ueber Blizzard UISpecialFrames registriert (Ingame-Verifikation offen).
- X und Blizzard-Taschenleistenbutton erhalten vorbereitete Secure-Handler-Wrappers, wenn deren Frames im Client geschuetzt sind.
- Keine globale ESC-Uebersteuerung; Abschaltung verhindert weitere Wrapper-Aktionen.
- Noch NICHT bei CurseForge hochladen: zuerst Ingame-Regressionstests.

# AdiBagsForever b0.1.10 r2 – Test (not published)

**Target:** WoW Forever 1.60.1 (interface 16001)

Fixes based on r1 in-game feedback:
- Defers secure combat bag prewarm to the next UI tick, after Ace filter modules initialize.
- Guards the Junk filter against uninitialized preferences during early scans.
- Switches off secure item-equipping right-click actions while a merchant is open (outside combat).
- Uses a deliberate player right-click to pick up a sellable bag item and place it on the merchant using the public cursor API. Does not bulk-sell or override protected UseContainerItem.
- Normal right-click item use outside merchants, left-click pickup, bank handling and secure combat-bag key logic retained.

**Must be tested in-game:** merchant sale of a non-equipped item (including wearable equipment and stacked goods), item use after merchant closes, bag opening while in combat, no BugSack errors.

**Known limitations:** the merchant cursor-selling API path is unconfirmed on Forever and may leave an item on the cursor if the client rejects the sale; in that case put the item back manually. No auto-junk selling, and bank-bag right-click is still limited. Do not test with valuable items. The public CurseForge v0.1.9 r1 is unchanged.

## b0.1.10 r3 – Händler-Rechtsklick (Testversion)

- Fix für nicht verkaufbare Rüstungsgegenstände in der eigenen Taschenansicht: ausdrücklich inaktive sichere Rechtsklick-Aktion am Händler (`type2=none` statt `nil`).
- Tatsächlich geöffnetes Händlerfenster wird direkt vor dem Klick überprüft.
- Die Händler-Ereignisabonnements pro Gegenstands-Button sind entfallen; das verringert die Komplexität.
- Kein automatischer Gegenstandsverkauf und keine Veränderung von Blizzards geschützten Funktionen.
- **Nicht im Spiel bestätigt**: Verkauf tragbarer Ausrüstung über den Cursor-Verkaufsweg. Unveränderte öffentliche Version v0.1.9 r1.
