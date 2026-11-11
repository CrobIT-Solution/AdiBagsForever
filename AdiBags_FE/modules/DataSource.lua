--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2021 Adirelle (adirelle@gmail.com)
All rights reserved.

This file is part of AdiBags.

AdiBags is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

AdiBags is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AdiBags.  If not, see <http://www.gnu.org/licenses/>.
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local AddonCompartmentFrame = _G.AddonCompartmentFrame
local format = _G.format
local GameTooltip = _G.GameTooltip
local GetAddOnMetadata = _G.C_AddOns.GetAddOnMetadata
local GetContainerNumFreeSlots = C_Container and _G.C_Container.GetContainerNumFreeSlots or _G.GetContainerNumFreeSlots
local GetContainerNumSlots = C_Container and _G.C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local ipairs = _G.ipairs
local pairs = _G.pairs
local REAGENTBAG_CONTAINER = ( Enum.BagIndex and Enum.BagIndex.REAGENTBAG_CONTAINER ) or 5
local strjoin = _G.strjoin
local tconcat = _G.table.concat
local tinsert = _G.tinsert
local wipe = _G.wipe
--GLOBALS>

local mod = addon:NewModule('DataSource', 'ABEvent-1.0', 'ABBucket-1.0')
mod.uiName = L['LDB Plugin']
mod.uiDesc = L['Provides a LDB data source to be displayed by LDB display addons.']
mod.cannotDisable = true

local dataObject = {
	type = "data source",
	label = addonName,
	text = addonName,
	icon = [[Interface\Icons\INV_Misc_Bag_08]],
	-- Both clicks open settings. Bag toggling belongs to the native bag key.
	OnClick = function()
		addon:OpenOptions()
	end,
	OnEnter = function(self)
		local r, g, b = 0.2, 1, 0.2
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddDoubleLine(addonName, GetAddOnMetadata(addonName, "Version"))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Klicken: AdiBagsForever-Einstellungen öffnen", r, g, b)
		GameTooltip:AddLine("Ziehen: Position an der Minimap ändern", 0.8, 0.8, 0.8)
		GameTooltip:Show()
	end,
	OnLeave = function()
		GameTooltip:Hide()
	end,
}

function mod:OnInitialize()
	-- Database will be initialized in OnEnable after main addon is ready
end

-- WoW Forever: self-contained minimap launcher; does not depend on a separate
-- minimap addon or on the Addon Compartment being visible.
local function CreateForeverMinimapButton()
    if not addon.isForever or not Minimap or not CreateFrame then return end
    local settings = addon.db and addon.db.profile
    if not settings then return end
    if type(settings.minimapPosition) ~= "number" then settings.minimapPosition = 225 end
    local button = CreateFrame("Button", "AdiBags_FEMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    -- Follow the standard 31px minimap-button geometry.  The old 52px
    -- tracking border was CENTER-anchored, offsetting its visible ring
    -- relative to the icon when collected by MinimapButtonButton (MBB).
    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetSize(20, 20)
    background:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(dataObject.icon)
    icon:SetSize(20, 20)
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    button.icon = icon
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    local function Position()
        local angle = math.rad(settings.minimapPosition)
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * 80, math.sin(angle) * 80)
    end
    button:SetScript("OnClick", function()
        addon:OpenOptions()
    end)
    button:SetScript("OnEnter", dataObject.OnEnter)
    button:SetScript("OnLeave", dataObject.OnLeave)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            local angle = math.deg(math.atan2(cy / scale - my, cx / scale - mx))
            settings.minimapPosition = angle
            Position()
        end)
    end)
    button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    Position()
    return button
end

local created = false
function mod:OnEnable()
	-- Initialize database here when main addon is ready
	if not self.db then
		self.db = addon.db:RegisterNamespace(self.moduleName, {
			profile = {
				format = 'free/total',
				showBank = true,
				mergeBags = false,
				showIcons = true,
				showTags = true,
			},
		})
	end
	
	if not created then
		-- Addon compartment:
		-- https://warcraft.wiki.gg/wiki/Addon_compartment
		if AddonCompartmentFrame then
			AddonCompartmentFrame:RegisterAddon({
				text = addonName,
				icon = dataObject.icon,
				func = dataObject.OnClick,
				funcOnEnter = dataObject.OnEnter,
				funcOnLeave = dataObject.OnLeave,
				registerForAnyClick = true,
				notCheckable = true,
			})
		end

		LibStub('LibDataBroker-1.1'):NewDataObject(addonName, dataObject)
		created = true
		self.foreverMinimapButton = CreateForeverMinimapButton()
	end
	self:RegisterBucketEvent('BAG_UPDATE', 0.5, "Update")
	if addon.isRetail or addon.isWrath or addon.isCata then
		self:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', 'BANKFRAME_OPENED')
		self:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', 'BANKFRAME_CLOSED')
	else
		self:RegisterEvent('BANKFRAME_OPENED')
		self:RegisterEvent('BANKFRAME_CLOSED')
	end
	self:Update()
end

function mod:BANKFRAME_OPENED(e, kind)
	if addon.isRetail or addon.isWrath or addon.isCata then
		if kind == Enum.PlayerInteractionType.Banker then
			self.atBank = true
			return self:Update()
		end
	else
		self.atBank = true
		return self:Update()
	end
end

function mod:BANKFRAME_CLOSED(e, kind)
	if addon.isRetail or addon.isWrath or addon.isCata then
		if kind == Enum.PlayerInteractionType.Banker then
			self.atBank = false
			return self:Update()
		end
	else
		self.atBank = false
		return self:Update()
	end
end

local FAMILY_ORDER = {
	0x00000, -- Regular bag
	0x00001, -- Quiver
	0x00002, -- Ammo Pouch
	0x00004, -- Soul Bag
	0x00008, -- Leatherworking Bag
	0x00010, -- Inscription Bag
	0x00020, -- Herb Bag
	0x00040, -- Enchanting Bag
	0x00080, -- Engineering Bag
	0x00100, -- Keyring
	0x00200, -- Gem Bag
	0x00400, -- Mining Bag
	0x00800, -- Reagent Bag
	0x08000, -- Tackle Box
	0x10000, -- Refrigerator
}

local size = {}
local free = {}
local data = {}

local FORMATS = {
	['free/total'] = "%1$d/%2$d",
	['inUse/total'] = "%3$d/%2$d",
	['free'] = "%1$d",
	['inUse'] = "%3$d",
}

local function BuildSpaceString(bags)
	wipe(size)
	wipe(free)
	for bag in pairs(bags) do
		local bagSize = GetContainerNumSlots(bag)
		if bagSize and bagSize > 0 then
			local bagFree, bagFamily = GetContainerNumFreeSlots(bag)
			bagFamily = bagFamily or 0
			bagFree = bagFree or 0
			if mod.db.profile.mergeBags then bagFamily = 0 end
			size[bagFamily] = (size[bagFamily] or 0) + bagSize
			free[bagFamily] = (free[bagFamily] or 0) + bagFree
		end
	end
	wipe(data)
	local spaceformat = FORMATS[mod.db.profile.format]
	local showIcons, showTags = mod.db.profile.showIcons, mod.db.profile.showTags
	local numIcons = 0
	for i, family in ipairs(FAMILY_ORDER) do
		if size[family] then
			local tag, icon = addon:GetFamilyTag(family)
			local text = spaceformat:format(free[family], size[family], size[family] - free[family])
			if showIcons and icon then
				numIcons = numIcons + 1 -- fix a bug with fontstring embedding several textures
				text = format("%s|T%s:0:0:0:%d:64:64:4:60:4:60|t", text, icon, -numIcons)
			elseif (showIcons or showTags) and tag then
				text = strjoin(':', tag, text)
			end
			tinsert(data, text)
		end
	end
	return tconcat(data, " ")
end

function mod:Update(event)
	local bags = BuildSpaceString(addon.BAG_IDS.BAGS)
	if self.atBank and self.db.profile.showBank then
		dataObject.text = format("%s |cff7777ff%s|r", bags, BuildSpaceString(addon.BAG_IDS.BANK))
	else
		dataObject.text = bags
	end
end

function mod:GetOptions()
	return {
		format = {
			name = L['Bag usage format'],
			desc = L['Select how bag usage should be formatted in the plugin.'],
			type = 'select',
			order = 10,
			values = {
				['free/total'] = L['Free space / total space'],
				['inUse/total'] = L['Space in use / total space'],
				['free'] = L['Free space'],
				['inUse'] = L['Space in use']
			}
		},
		showBank = {
			name = L['Show bank usage'],
			disabled = function() return addon.useBlizzardBank end,
			desc = L['Check this to show space at your bank in the plugin.'],
			type = 'toggle',
			order = 20,
		},
		mergeBags = {
			name = L['Merge bag types'],
			desc = L['Check this to display only one value counting all equipped bags, ignoring their type.'],
			type = 'toggle',
			order = 30,
		},
		showIcons = {
			name = L['Show bag type icons'],
			desc = L['Check this to display an icon after usage of each type of bags.'],
			type = 'toggle',
			order = 40,
			disabled = function(info) return info.handler:IsDisabled(info) or self.db.profile.mergeBags end,
		},
		showTags = {
			name = L['Show bag type tags'],
			desc = L['Check this to display an textual tag before usage of each type of bags.'],
			type = 'toggle',
			order = 50,
			disabled = function(info) return info.handler:IsDisabled(info) or self.db.profile.mergeBags end,
		},
	}, addon:GetOptionHandler(self, false, function() return self:Update() end)
end
