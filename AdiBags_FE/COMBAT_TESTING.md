# AdiBagsForever b0.1.10 r2 – Combat test (NOT public release)

## Why
SecureActionButtonTemplate item buttons propagate protected status to the bag container. Insecure frame:Show() or :Hide() cannot be used during combat.

## Change
A SecureHandlerClickTemplate named AdiBags_FECombatBagToggle uses a preconfigured FrameRef to the prepared backpack. It is bound to the player's existing TOGGLEBACKPACK / OPENALLBAGS / TOGGLEALLBAGS keys via SetOverrideBindingClick outside combat. A user keypress executes the protected show/hide operation in a secure restricted handler. No protected operation is called from insecure Lua while in combat. Layout and item button reassignments are deferred until PLAYER_REGEN_ENABLED.

## Limitations
- This is untested in the Forever game client. In-combat action must be confirmed with BugSack enabled.
- Only keyboard bag bindings are routed through the secure handler. Other ways of opening bags in combat may still not work.
- The inventory is a pre-combat snapshot; item refreshes are deferred until combat ends. Do not rely on changing slot contents shown during combat.
- MBB minimap-button grouping remains a separate issue. The minimap button still opens SETTINGS ONLY.
- No modifications have been made to the CurseForge v0.1.9 r1 submission.

## In-game checklist
1. Start WoW outside combat. Confirm backpack and settings open normally. Confirm BugSack is empty.
2. Close bag. Enter combat and press your existing backpack key (usually B). Expect categorized bag to open; press again to close. Repeat with the open-all-bags key (often Shift+B), if assigned.
3. In combat: inspect displayed items; DO NOT move or sell valuable items. Test a harmless usable item only if its appearance matches the actual slot.
4. Leave combat: confirm that all item icons/counts refresh and bag toggling still works outside combat.
5. Check BugSack for ADDON_ACTION_BLOCKED / ADDON_ACTION_FORBIDDEN. If any error, revert to the last tested v0.1.9 r1 (or a0.1.8 r4) and report its full stack.

Additional r2 checks: open bag on login (no Junk.lua nil prefs); open merchant; right-click harmless ordinary item and wearable equip; close merchant and use a harmless consumable; enter combat and toggle bag with normal key.
