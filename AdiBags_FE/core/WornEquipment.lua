--[[
AdiBags_FE - equipment wear-history sorting for WoW Forever.
Copyright 2010-2021 Adirelle and subsequent AdiBagsEx contributors.
This modification is distributed under GPL-3.0-or-later; see LICENSE.

An item type (itemID or hyperlink) is NOT an instance. Only an item GUID
observed while actually equipped may be entered in the worn-item history.
--]]
local addonName, addon = ...
local L = addon.L
local _G = _G
local C_Item = _G.C_Item
local ItemLocation = _G.ItemLocation
local issecretvalue = _G.issecretvalue
local InCombatLockdown = _G.InCombatLockdown
local pcall, type, pairs = _G.pcall, _G.type, _G.pairs

local BOE, BOP = 'BoE', 'BoP'
local UNWORN = _G.GetLocale and _G.GetLocale() == 'deDE' and 'Ungetragen' or 'Unworn'
local EQUIPMENT = L['Equipment']
local BIND = (_G.Enum and _G.Enum.ItemBind) or {}
local BIND_ON_PICKUP = BIND.OnAcquire or 1
local BIND_ON_EQUIP = BIND.OnEquip or 2

-- Containers and ammunition are not character gear, even though they have
-- inventory-type tokens. Keep using the existing category filters for them.
local excludedTypes = {
    INVTYPE_BAG = true,
    INVTYPE_AMMO = true,
    INVTYPE_QUIVER = true,
    INVTYPE_NON_EQUIP_IGNORE = true,
}
local function IsWearableEquipment(equipSlot)
    if issecretvalue and issecretvalue(equipSlot) then return false end
    return type(equipSlot) == 'string' and equipSlot ~= ''
        and not excludedTypes[equipSlot]
end

-- Referenced by the virtual-stack logic: two physically different items must
-- never be collapsed together when only one was worn.
addon.IsWearableEquipment = IsWearableEquipment

if addon.isForever then
    addon:SetCategoryOrder(BOE, 18)
    addon:SetCategoryOrder(BOP, 17)
    addon:SetCategoryOrder(UNWORN, 16)

    -- 95: manual override; 94: worn/BoE/BoP; 90: Blizzard equipment sets.
    local mod = addon:RegisterFilter('WornEquipment', 94, 'ABEvent-1.0')
    mod.uiName = _G.GetLocale and _G.GetLocale() == 'deDE' and 'Tragehistorie (BoE/BoP)' or 'Wear history (BoE/BoP)'
    mod.uiDesc = _G.GetLocale and _G.GetLocale() == 'deDE'
        and 'Ungetragene Ausruestung bleibt in BoE, BoP oder Ungetragen. Erst nach tatsaechlichem Anlegen wechselt genau dieses Exemplar zu Equipment. Manuelle Filter bleiben vorrangig.'
        or 'Unworn gear remains in BoE, BoP or Unworn. Only an individual item observed equipped is assigned to Equipment. Manual overrides take priority.'

    local function SafeEquippedGUID(slot)
        if not ItemLocation or type(ItemLocation.CreateFromEquipmentSlot) ~= 'function'
            or not C_Item or type(C_Item.GetItemGUID) ~= 'function' then
            return nil
        end
        if InCombatLockdown and InCombatLockdown() then
            return nil
        end
        local ok, location = pcall(ItemLocation.CreateFromEquipmentSlot, ItemLocation, slot)
        if not ok or not location then return nil end
        return addon:GetSafeItemGUID(location)
    end

    function mod:OnEnable()
        if not self.db then
            self.db = addon.db:RegisterNamespace(self.moduleName, {
                char = { wornGUIDs = {} },
            })
        end
        if type(self.db.char.wornGUIDs) ~= 'table' then
            self.db.char.wornGUIDs = {}
        end
        self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
        self:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        self:ScanEquipment()
    end

    function mod:MarkEquippedSlot(slot)
        local guid = SafeEquippedGUID(slot)
        if not guid then return false end
        local worn = self.db.char.wornGUIDs
        if worn[guid] then return false end
        worn[guid] = true
        return true
    end

    function mod:ScanEquipment()
        local first = _G.INVSLOT_FIRST_EQUIPPED or 1
        local last = _G.INVSLOT_LAST_EQUIPPED or 19
        local changed = false
        for slot = first, last do
            if self:MarkEquippedSlot(slot) then changed = true end
        end
        if changed then
            self:SendMessage('AdiBags_FE_FiltersChanged', true)
        end
    end

    function mod:PLAYER_EQUIPMENT_CHANGED(event, slot)
        -- Ignore the ambiguous hasCurrent boolean; inspect the slot itself.
        if type(slot) ~= 'number' then return end
        if self:MarkEquippedSlot(slot) then
            self:SendMessage('AdiBags_FE_FiltersChanged', true)
        end
    end

    function mod:EQUIPMENT_SWAP_FINISHED() self:ScanEquipment() end
    function mod:PLAYER_ENTERING_WORLD() self:ScanEquipment() end
    function mod:PLAYER_REGEN_ENABLED() self:ScanEquipment() end

    function mod:Filter(slotData)
        if not IsWearableEquipment(slotData.equipSlot) then return nil end
        local guid = slotData.guid
        if guid and (not issecretvalue or not issecretvalue(guid))
            and self.db.char.wornGUIDs[guid] then
            return EQUIPMENT, EQUIPMENT
        end
        -- The item type's original bind rule, not its current soulbound state.
        if slotData.bindType == BIND_ON_EQUIP then return BOE, BOE end
        if slotData.bindType == BIND_ON_PICKUP then return BOP, BOP end
        return UNWORN, UNWORN
    end
end
