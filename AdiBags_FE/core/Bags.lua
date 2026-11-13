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
local BankFrame = _G.BankFrame
local OpenAllBags = _G.OpenAllBags
local CloseAllBags = _G.CloseAllBags
local IsBagOpen = _G.IsBagOpen
local CloseBankFrame = C_Bank and _G.C_Bank.CloseBankFrame or _G.CloseBankFrame
local SortBags = C_Container and _G.C_Container.SortBags or _G.SortBags
local SortBankBags = C_Container and _G.C_Container.SortBankBags or _G.SortBankBags
local SortReagentBankBags = C_Container and _G.C_Container.SortReagentBankBags or _G.SortReagentBankBags
local ipairs = _G.ipairs
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local tinsert = _G.tinsert
local tsort = _G.table.sort
--GLOBALS>

local hookedBags = addon.hookedBags

--------------------------------------------------------------------------------
-- Bag prototype
--------------------------------------------------------------------------------

local bagProto = setmetatable({
	isBag = true,
}, { __index = addon.moduleProto })
addon.bagProto = bagProto

function bagProto:OnEnable()
	local open = false
	for id in pairs(self.bagIds) do
		local frame = addon:GetContainerFrame(id)
		if IsBagOpen(id) then
			open = true
		end
		hookedBags[id] = self
	end
	
	-- Only close bags for non-bank modules to avoid interference
	if not self.isBank then
		CloseAllBags()
	end
	
	if self.PostEnable then
		self:PostEnable()
	end
	self:Debug('Enabled')
	if open then
		self:Open()
	end
end

function bagProto:OnDisable()
	local open = self:IsOpen()
	self:Close()

	if self.bagIds then
		for id in pairs(self.bagIds) do
			hookedBags[id] = nil
		end
	end
	if open then
		OpenAllBags()
	end
	if self.PostDisable then
		self:PostDisable()
	end
	self:Debug('Disabled')
end

function bagProto:Open()
	if not self:CanOpen() then return end
	-- Forever's secure item buttons protect the surrounding bag frame.
	-- Only the secure keyboard handler may show it during combat.
	if addon.isForever and self.bagName == "Backpack" and InCombatLockdown() then
		return false
	end
	local frame = self:GetFrame()
	if not frame:IsShown() then
		self:Debug('Open')
		if self.PreOpen then
			self:PreOpen()
		end
		frame:Show()
		addon:SendMessage('AdiBags_BagOpened', self.bagName, self)
		return true
	end
end

function bagProto:Close()
	if addon.isForever and self.bagName == "Backpack" and InCombatLockdown() then
		return false
	end
	if self.frame and self.frame:IsShown() then
		self:Debug('Close')
		self.frame:Hide()
		addon:SendMessage('AdiBags_BagClosed', self.bagName, self)
		if self.PostClose then
			self:PostClose()
		end
		return true
	end
end

function bagProto:IsOpen()
	return self.frame and self.frame:IsShown()
end

function bagProto:CanOpen()
	return self:IsEnabled()
end

function bagProto:Toggle()
	if self:IsOpen() then
		self:Close()
	elseif self:CanOpen() then
		self:Open()
	end
end

function bagProto:HasFrame()
	return not not self.frame
end

function bagProto:GetFrame()
	if not self.frame then
		self.frame = self:CreateFrame()
		-- WoW 11.2.0 compatibility: CloseButton might not exist or have different name
		local closeButton = self.frame.CloseButton or self.frame.closeButton
			or (self.frame.GetCloseButton and self.frame:GetCloseButton())
		if closeButton and not (addon.isForever and self.bagName == "Backpack") then
			-- Forever's backpack X already owns its secure click handler.
			closeButton:SetScript('OnClick', function() self:Close() end)
		end
		addon:SendMessage('AdiBags_BagFrameCreated', self)
	end
	return self.frame
end

function bagProto:CreateFrame()
	return addon:CreateContainerFrame(self.bagName, self.isBank, self)
end

--------------------------------------------------------------------------------
-- Bags methods
--------------------------------------------------------------------------------

local bags = {}

local function CompareBags(a, b)
	return a.order < b.order
end

function addon:NewBag(name, order, isBank, ...)
	self:Debug('NewBag', name, order, isBank, ...)
	local bag = addon:NewModule(name, bagProto, 'ABEvent-1.0', ...)
	bag.bagName = name
	bag.bagIds = addon.BAG_IDS[isBank and "BANK" or "BAGS"]
	bag.isBank = isBank
	bag.order = order
	tinsert(bags, bag)
	tsort(bags, CompareBags)
	return bag
end

do
	local function iterateOpenBags(numBags, index)
		while index < numBags do
			index = index + 1
			local bag = bags[index]
			if bag:IsEnabled() and bag:IsOpen() then
				return index, bag
			end
		end
	end

	local function iterateBags(numBags, index)
		while index < numBags do
			index = index + 1
			local bag = bags[index]
			if bag:IsEnabled() then
				return index, bag
			end
		end
	end

	function addon:IterateBags(onlyOpen)
		return onlyOpen and iterateOpenBags or iterateBags, #bags, 0
	end
end

function addon:IterateDefinedBags()
	return ipairs(bags)
end

--------------------------------------------------------------------------------
-- Backpack
--------------------------------------------------------------------------------

do
	-- L["Backpack"]
	local backpack = addon:NewBag("Backpack", 10, false, 'AceHook-3.0')

	-- A SecureHandlerClickTemplate owns the combat bag key. A normal Lua
	-- callback cannot Show/Hide the protected container in combat. All secure
	-- references and override bindings are configured while outside combat.
	local combatBindingActions = { "TOGGLEBACKPACK", "OPENALLBAGS", "TOGGLEALLBAGS" }
	local function ConfigureCombatBagBindings(self)
		if InCombatLockdown() or not self.foreverCombatToggle then return end
		local owner = self.foreverCombatToggle
		-- Independent owners: clearing B never removes the ESC override.
		if self.foreverBarOwner then self.foreverBarOwner:SetAttribute("enabled", true) end
		if self.foreverEscOwner then
			self.foreverEscOwner:SetAttribute("enabled", true)
			if self.frame and self.frame:IsShown() then
				SetOverrideBindingClick(self.foreverEscOwner, true, "ESCAPE", self.foreverEscOwner:GetName(), "LeftButton")
			end
		end
		-- Keyboard-generated clicks may arrive on key-down, depending on the
		-- player's ActionButtonUseKeyDown setting. Handle exactly one edge.
		local getCVar = (C_CVar and C_CVar.GetCVarBool) or _G.GetCVarBool
		owner:SetAttribute("clickOnDown", getCVar and not not getCVar("ActionButtonUseKeyDown") or false)
		ClearOverrideBindings(owner)
		local seen = {}
		local function BindKey(key)
			if type(key) == "string" and key ~= "" and not seen[key] then
				seen[key] = true
				SetOverrideBindingClick(owner, true, key, owner:GetName(), "LeftButton")
			end
		end
		for _, action in ipairs(combatBindingActions) do
			local key1, key2 = GetBindingKey(action)
			-- ipairs({nil, key2}) misses key2 entirely: handle both keys explicitly.
			BindKey(key1)
			BindKey(key2)
		end
		self.foreverBindingSetupCount = (self.foreverBindingSetupCount or 0) + 1
	end

	function backpack:InitializeForeverCombatToggle()
		if not addon.isForever or InCombatLockdown() then return end
		if self.foreverCombatToggle then return ConfigureCombatBagBindings(self) end
		local bagFrame = self:GetFrame()
		-- Build the real item buttons, layout and secured slot assignments before
		-- combat. Hidden protected buttons cannot be initialized in a lockdown.
		local wasHidden = not bagFrame:IsShown()
		if wasHidden then
			bagFrame.foreverPrewarming = true
			bagFrame:SetAlpha(0)
			bagFrame:Show()
		end
		-- Bug analysis: normal out-of-combat opening sends BagOpened, which
		-- calls LayoutBags and applies the saved anchor. The secure combat B
		-- click intentionally skips that message, so a freshly prewarmed
		-- backpack can be IsShown=true but have no position on screen.
		-- Set the position and scale now, outside combat, while the bag is
		-- shown (the layout iterator only includes open bag frames).
		addon:LayoutBags()
		if bagFrame:GetNumPoints() == 0 then
			-- Only for missing/corrupt saved positions; never override an
			-- existing user anchor. No SavedVariables are changed here.
			bagFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -32, 200)
		end
		if wasHidden then
			-- OnUpdate cannot finish this after the hidden prewarm closes.
			-- Prepare secure item slots and geometry synchronously now.
			bagFrame:Layout()
			if bagFrame.dirtyLayout then bagFrame:Layout() end
			bagFrame:Hide()
			bagFrame:SetAlpha(1)
			bagFrame.foreverPrewarming = nil
		end
		local owner = CreateFrame("Button", addonName .. "CombatBagToggle", UIParent, "SecureHandlerClickTemplate")
		owner:SetSize(1, 1)
		owner:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -20, 0)
		owner:SetAlpha(0)
		-- WoW can dispatch bound clicks on key-down or key-up. The old
		-- AnyUp-only registration silently dropped key-down bindings.
		owner:RegisterForClicks("AnyDown", "AnyUp")
		owner:SetFrameRef("bag", bagFrame)
		owner:SetAttribute("_onclick", [[
			-- Diagnostic counters run entirely inside Blizzard's secure handler.
			-- They do not change click routing or the bag toggle itself.
			self:SetAttribute("abfDiagInvocations", (self:GetAttribute("abfDiagInvocations") or 0) + 1)
			if (not not down) == self:GetAttribute("clickOnDown") then
				self:SetAttribute("abfDiagAccepted", (self:GetAttribute("abfDiagAccepted") or 0) + 1)
				local bag = self:GetFrameRef("bag")
				if bag then
					self:SetAttribute("abfDiagBefore", bag:IsShown() and "sichtbar" or "verborgen")
					if bag:IsShown() then bag:Hide() else bag:Show() end
					self:SetAttribute("abfDiagAfter", bag:IsShown() and "sichtbar" or "verborgen")
				else
					self:SetAttribute("abfDiagAfter", "Bag-Referenz fehlt")
				end
			end
		]])
		owner:HookScript("OnClick", function()
			-- Do not trigger layout or unsecured bag functions in combat.
			if InCombatLockdown() then return end
			if bagFrame:IsShown() then
				addon:SendMessage("AdiBags_BagOpened", self.bagName, self)
			else
				addon:SendMessage("AdiBags_BagClosed", self.bagName, self)
			end
		end)
		self.foreverCombatToggle = owner
		local listener = CreateFrame("Frame")
		listener:RegisterEvent("UPDATE_BINDINGS")
		listener:RegisterEvent("PLAYER_REGEN_ENABLED")
		listener:RegisterEvent("CVAR_UPDATE")
		listener:SetScript("OnEvent", function(_, event, cvar)
			if event == "CVAR_UPDATE" and cvar ~= "ActionButtonUseKeyDown" then return end
			if self:IsEnabled() and not InCombatLockdown() then
				ConfigureCombatBagBindings(self)
			end
		end)
		self.foreverCombatBindingListener = listener

		-- Do not replace Blizzard's protected scripts with insecure Lua.
		-- The extra bar wrapper and the conditional ESC binding each have
		-- their own secure owner, separate from the tested B binding.
		local secureWrap = _G.SecureHandlerWrapScript
		if type(secureWrap) == "function" then
			if bagFrame:IsProtected() then
				local esc = CreateFrame("Button", addonName .. "CombatEscapeClose", UIParent, "SecureHandlerClickTemplate")
				esc:SetSize(1, 1)
				esc:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -20, 0)
				esc:SetAlpha(0)
				esc:RegisterForClicks("AnyDown", "AnyUp")
				esc:SetFrameRef("bag", bagFrame)
				esc:SetAttribute("enabled", true)
				esc:SetAttribute("_onclick", [[
					if button == "LeftButton" then
						local bag = self:GetFrameRef("bag")
						if bag and bag:IsShown() then bag:Hide() end
					end
				]])
				-- Scoped ESC: install only when the bag is shown, remove
				-- on hide. Never assign ESC globally or permanently.
				local showOk = pcall(secureWrap, bagFrame, "OnShow", esc, [[
					if control:GetAttribute("enabled") then
						control:SetBindingClick(true, "ESCAPE", control:GetName(), "LeftButton")
					end
				]])
				local hideOk = showOk and pcall(secureWrap, bagFrame, "OnHide", esc, [[
					control:ClearBindings()
				]])
				if showOk and hideOk then
					self.foreverEscOwner = esc
					self.foreverEscStatus = "aktiv"
					if bagFrame:IsShown() then
						SetOverrideBindingClick(esc, true, "ESCAPE", esc:GetName(), "LeftButton")
					end
				else
					-- Roll back any half-installed show wrapper to avoid
					-- leaving ESC stolen if the hide wrapper could not attach.
					if showOk and type(_G.SecureHandlerUnwrapScript) == "function" then
						pcall(_G.SecureHandlerUnwrapScript, bagFrame, "OnShow")
					end
					self.foreverEscStatus = "nicht verfuegbar"
				end
			else
				self.foreverEscStatus = "Taschenfenster ungeschuetzt"
			end

			local bar = _G.MainMenuBarBackpackButton
			if bar and bar.IsProtected and bar:IsProtected() then
				local barOwner = CreateFrame("Frame", addonName .. "CombatBagBarOwner", UIParent, "SecureHandlerBaseTemplate")
				barOwner:SetFrameRef("bag", bagFrame)
				barOwner:SetAttribute("enabled", true)
				-- The default Blizzard click leads to insecure bag hooks.
				-- Route a real left-click through a secure restricted snippet;
				-- returning false suppresses only the handled default click.
				local barOk = pcall(secureWrap, bar, "OnClick", barOwner, [[
					if button == "LeftButton" and control:GetAttribute("enabled") then
						local bag = control:GetFrameRef("bag")
						if bag then
							if bag:IsShown() then bag:Hide() else bag:Show() end
							return false
						end
					end
				]])
				if barOk then
					self.foreverBarOwner = barOwner
					self.foreverBarStatus = "aktiv"
				else
					self.foreverBarStatus = "Wrapper abgelehnt"
				end
			else
				self.foreverBarStatus = "Button fehlt oder ungeschuetzt"
			end
		else
			self.foreverEscStatus = "SecureHandlerWrapScript fehlt"
			self.foreverBarStatus = "SecureHandlerWrapScript fehlt"
		end

		-- Read-only diagnostic: no protected calls or binding changes in combat.
		-- Reports whether the combat-safe key binding was actually installed.
		addon:RegisterChatCommand("abfcombatdebug", function()
			-- Read-only diagnostic. Never install, clear or modify bindings here.
			local f, btn = self.frame, self.foreverCombatToggle
			local status = InCombatLockdown() and "Kampf" or "kein Kampf"
			local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or _G.GetAddOnMetadata
			local version = getMeta and getMeta(addonName, "Version") or "unbekannt"
			print("|cff33ccffAdiBagsForever|r " .. tostring(version) .. " - " .. status)
			print("Tasche: " .. (f and (f:IsShown() and "sichtbar" or "verborgen") or "nicht erstellt"))
			if f then
				local x, y = f:GetCenter()
				print("Frame sichtbar=" .. tostring(f:IsVisible()) ..
					", Alpha=" .. tostring(f:GetAlpha()) ..
					", effektives Alpha=" .. tostring(f:GetEffectiveAlpha()))
				print("Frame Groesse=" .. tostring(f:GetWidth()) .. "x" .. tostring(f:GetHeight()) ..
					", Mitte=" .. tostring(x) .. "/" .. tostring(y) ..
					", Layout offen=" .. tostring(f.dirtyLayout))
				local point, _, _, offX, offY = f:GetPoint(1)
				print("Ankerpunkte=" .. tostring(f:GetNumPoints()) .. ", Punkt=" .. tostring(point) ..
					", Offset=" .. tostring(offX) .. "/" .. tostring(offY) ..
					", Vollupdate offen=" .. tostring(f.forceLayout))
			end
			print("Secure-Button: " .. (btn and btn:GetName() or "FEHLT"))
			if btn then
				print("Button sichtbar: " .. tostring(btn:IsVisible()) .. ", gezeigt: " .. tostring(btn:IsShown()))
				local getCVar = (C_CVar and C_CVar.GetCVarBool) or _G.GetCVarBool
				print("Klick beim Druecken (Button/CVar): " .. tostring(btn:GetAttribute("clickOnDown")) .. "/" .. tostring(getCVar and getCVar("ActionButtonUseKeyDown")))
				print("Sichere Klicks: eingetroffen=" .. tostring(btn:GetAttribute("abfDiagInvocations") or 0) .. ", angenommen=" .. tostring(btn:GetAttribute("abfDiagAccepted") or 0))
				print("Letzter Wechsel: " .. tostring(btn:GetAttribute("abfDiagBefore") or "-") .. " -> " .. tostring(btn:GetAttribute("abfDiagAfter") or "-"))
			end
			print("ESC: " .. tostring(self.foreverEscStatus or "noch nicht eingerichtet") ..
				", Bindung=" .. tostring(_G.GetBindingAction and _G.GetBindingAction("ESCAPE", true) or "?"))
			print("Blizzard-Taschenbutton: " .. tostring(self.foreverBarStatus or "noch nicht eingerichtet"))
			print("Bindungs-Setups seit UI-Start: " .. tostring(self.foreverBindingSetupCount or 0))
			print("Welteintritte seit UI-Start: " .. tostring(self.foreverWorldEntryCount or 0))
			local expected = btn and ("CLICK " .. btn:GetName() .. ":LeftButton") or ""
			local anyKey = false
			for _, action in ipairs(combatBindingActions) do
				local first, second = GetBindingKey(action)
				for _, key in ipairs({first or "", second or ""}) do
					if key ~= "" then
						anyKey = true
						local effective = _G.GetBindingAction and _G.GetBindingAction(key, true) or "unbekannt"
						local normal = _G.GetBindingAction and _G.GetBindingAction(key, false) or "unbekannt"
						local matches = expected ~= "" and effective == expected
						print(action .. " [" .. key .. "]: " .. (matches and "OK" or "ABWEICHUNG"))
						print("  normal=" .. tostring(normal) .. ", aktiv=" .. tostring(effective))
					end
				end
			end
			if not anyKey then print("Keine Tasten fuer Taschenaktionen eingetragen") end
		end)
		ConfigureCombatBagBindings(self)
	end

	local function DeferForeverCombatSetup(self)
		if not self:IsEnabled() then return end
		if InCombatLockdown() then
			if self.foreverPendingCombatSetup then return end
			local listener = CreateFrame('Frame')
			self.foreverPendingCombatSetup = listener
			listener:RegisterEvent('PLAYER_REGEN_ENABLED')
			listener:SetScript('OnEvent', function(frame)
				frame:UnregisterEvent('PLAYER_REGEN_ENABLED')
				self.foreverPendingCombatSetup = nil
				C_Timer.After(0, function() DeferForeverCombatSetup(self) end)
			end)
			return
		end
		self:InitializeForeverCombatToggle()
	end

	-- WoW drops override key bindings on /reload. Reapply the existing
	-- combat-safe binding after world entry, when the UI has reloaded.
	-- No new key handler or global key remapping is created.
	function backpack:ForeverRebindOnWorldEntry()
		self.foreverWorldEntryCount = (self.foreverWorldEntryCount or 0) + 1
		C_Timer.After(0, function() DeferForeverCombatSetup(self) end)
	end

	function backpack:PostEnable()
		addon:EnableHooks()
		self:RegisterMessage('AdiBags_InteractingWindowChanged')
		if addon.isForever then
			self:RegisterEvent('PLAYER_ENTERING_WORLD', 'ForeverRebindOnWorldEntry')
			-- PostEnable is called before other filter modules have OnEnabled.
			-- Prewarming Show() here used to crash Junk.lua (prefs == nil).
			C_Timer.After(0, function() DeferForeverCombatSetup(self) end)
		end
	end

	function backpack:AdiBags_InteractingWindowChanged(event, window)
		if window then
			if addon.db.profile.autoOpen then
				self.wasOpen = self:IsOpen()
				if not self.wasOpen then
					self:Open()
				end
			end
		elseif self:IsOpen() and not self.wasOpen then
			self:Close()
		end
	end

	function backpack:Sort()
		PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
		SortBags()
		C_Timer.After(1, function() addon:OpenBackpack() end)
	end

	function backpack:PostDisable()
		addon:DisableHooks()
		if not InCombatLockdown() then
			if self.foreverCombatToggle then
				ClearOverrideBindings(self.foreverCombatToggle)
			end
			if self.foreverEscOwner then
				ClearOverrideBindings(self.foreverEscOwner)
				self.foreverEscOwner:SetAttribute("enabled", false)
			end
			if self.foreverBarOwner then
				self.foreverBarOwner:SetAttribute("enabled", false)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Character Bank
--------------------------------------------------------------------------------

do
	-- L["Bank"]
	local charBank = addon:NewBag("Bank", 20, true, 'AceHook-3.0')
	
	-- Override bagIds to only include character bank containers
	charBank.bagIds = addon.BAG_IDS.BANK_ONLY

	local UIHider = CreateFrame("Frame")
	UIHider:Hide()

	local function NOOP() end

	function charBank:PostEnable()
		self:RegisterMessage('AdiBags_InteractingWindowChanged')

		self:RawHookScript(BankFrame, "OnEvent", NOOP, true)
		self:RawHookScript(BankFrame, "OnShow", NOOP, true)
		self:RawHookScript(BankFrame, "OnHide", NOOP, true)
		self:RawHook(BankFrame, "GetRight", "BankFrameGetRight", true)
		self:Hook(BankFrame, "Show", "Open", true)
		self:Hook(BankFrame, "Hide", "Close", true)

		BankFrame:SetParent(UIHider)

		if addon:GetInteractingWindow() == "BANKFRAME" then
			self:Open()
		end
	end

	function charBank:PostDisable()
		if addon:GetInteractingWindow() == "BANKFRAME" then
			self.hooks[BankFrame].Show(BankFrame)
		end
		BankFrame:SetParent(UIParent)
	end

	function charBank:AdiBags_InteractingWindowChanged(event, new, old)
		if new == 'BANKFRAME' and not self:IsOpen() then
			self:Open()
		elseif old == 'BANKFRAME' and self:IsOpen() then
			self:Close()
		end
	end

	function charBank:CanOpen()
		return self:IsEnabled() and addon:GetInteractingWindow() == "BANKFRAME"
	end

	function charBank:PreOpen()
		self.hooks[BankFrame].Show(BankFrame)
		if addon.isRetail and addon.db.profile.autoDeposit and not IsModifierKeyDown() then
			DepositReagentBank()
		end
	end

	function charBank:PostClose()
		self.hooks[BankFrame].Hide(BankFrame)
		CloseBankFrame()
	end

	function charBank:Sort(isReagentBank)
		PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
		if isReagentBank then
			SortReagentBankBags()
		else
			SortBankBags()
		end
	end

	function charBank:BankFrameGetRight()
		return 0
	end

	if addon.isForever then
		-- Forever is a Mainline-family client with a different bank-tab model.
		-- Keep the entire Blizzard bank available and add a separate, categorized
		-- companion window. NEVER install the legacy BankFrame hooks above.
		local bankType = Enum and Enum.BankType and Enum.BankType.Character
		local api = C_Bank
		local containerAPI = C_Container

		local function HasPurchasedCharacterTab(self)
			if not api or type(api.FetchPurchasedBankTabIDs) ~= 'function'
				or bankType == nil or not containerAPI
				or type(containerAPI.GetContainerNumSlots) ~= 'function' then
				return false
			end
			local ids = api.FetchPurchasedBankTabIDs(bankType)
			if type(ids) ~= 'table' then return false end
			for _, id in ipairs(ids) do
				-- Only known CharacterBankTab enums; never account or keyring.
				if self.bagIds[id] then
					local size = containerAPI.GetContainerNumSlots(id)
					if type(size) == 'number' and size > 0 then return true end
				end
			end
			return false
		end

		function charBank:OnEnable()
			-- Avoid bagProto:OnEnable(), which replaces Blizzard bag hooks.
			self:RegisterEvent('BANKFRAME_OPENED', 'ForeverBankOpened')
			self:RegisterEvent('BANKFRAME_CLOSED', 'ForeverBankClosed')
			self:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', 'ForeverInteractionShow')
			self:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', 'ForeverInteractionHide')
			self:RegisterEvent('BAG_UPDATE_DELAYED', 'ForeverBankInventoryChanged')
			if api and api.CanViewBank and bankType ~= nil
				and api.CanViewBank(bankType) then
				self:ForeverBankOpened()
			end
		end

		function charBank:OnDisable()
			self:Close()
			self:UnregisterAllEvents()
			self.atForeverBank = nil
		end

		function charBank:ForeverBankOpened()
			self.atForeverBank = true
			-- Bank data can become available one frame after BANKFRAME_OPENED.
			C_Timer.After(0, function()
				if not self:IsEnabled() or not self.atForeverBank then return end
				if HasPurchasedCharacterTab(self) then self:Open() end
			end)
		end

		function charBank:ForeverBankClosed()
			self.atForeverBank = false
			self:Close()
		end

		function charBank:ForeverInteractionShow(event, kind)
			local banker = Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.Banker
			if banker ~= nil and kind == banker then self:ForeverBankOpened() end
		end

		function charBank:ForeverInteractionHide(event, kind)
			local banker = Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.Banker
			if banker ~= nil and kind == banker then self:ForeverBankClosed() end
		end

		function charBank:ForeverBankInventoryChanged()
			-- A bank tab may become queryable only after the banker opens.
			if self:IsEnabled() and self.atForeverBank and not self:IsOpen()
				and HasPurchasedCharacterTab(self) then self:Open() end
		end

		function charBank:CanOpen()
			return self:IsEnabled() and self.atForeverBank and HasPurchasedCharacterTab(self)
		end

		function charBank:PreOpen()
			-- The native BankFrame remains untouched throughout this operation.
		end

		function charBank:PostClose()
			-- Do not close, hide or reparent the native BankFrame!
		end

		function charBank:Sort()
			-- Only on an explicit click of this bank window's sort button.
			if not self:CanOpen() then return end
			if containerAPI and type(containerAPI.SortBank) == 'function' then
				containerAPI.SortBank(bankType)
			end
		end
	end

end

--------------------------------------------------------------------------------
-- Warband Bank
--------------------------------------------------------------------------------

do
	-- L["Warband Bank"]  
	local warbandBank = addon:NewBag("WarbandBank", 21, true, 'AceHook-3.0')
	
	-- Override bagIds to only include warband bank containers
	warbandBank.bagIds = addon.BAG_IDS.WARBOUNDBANK_ONLY

	local UIHider = CreateFrame("Frame")
	UIHider:Hide()

	local function NOOP() end

	function warbandBank:PostEnable()
		self:RegisterMessage('AdiBags_InteractingWindowChanged')
		self:RegisterMessage('AdiBags_BagFrameCreated')
		
		-- Warband bank does NOT open automatically when at bank
		-- It only opens when the W button is clicked
	end

	function warbandBank:AdiBags_BagFrameCreated(event, bag)
		-- If the character bank frame was just created and we're open, reposition ourselves
		if bag and bag.bagName == "Bank" and self:IsOpen() then
			self:PositionRelativeToCharacterBank()
		end
	end

	function warbandBank:PostDisable()
		-- Nothing special needed for warband bank disable
	end

	function warbandBank:AdiBags_InteractingWindowChanged(event, new, old)
		-- When leaving the bank, close the warband bank if it's open
		if old == 'BANKFRAME' and self:IsOpen() then
			self:Close()
		end
		-- Do NOT auto-open when entering bank - user must click W button
	end

	function warbandBank:CanOpen()
		return self:IsEnabled() and addon:GetInteractingWindow() == "BANKFRAME"
	end

	function warbandBank:PreOpen()
		-- Position warband bank to the right of character bank with aligned tops
		self:PositionRelativeToCharacterBank()
	end

	function warbandBank:PositionRelativeToCharacterBank()
		-- Get the character bank module and its frame
		local charBank = addon:GetModule("Bank", true)
		if not charBank or not charBank:IsEnabled() or not charBank:HasFrame() then
			return
		end
		
		local charBankFrame = charBank:GetFrame()
		local warbandFrame = self:GetFrame()
		
		if charBankFrame and warbandFrame then
			-- Position warband bank to the right of character bank with aligned tops
			warbandFrame:ClearAllPoints()
			warbandFrame:SetPoint("TOPLEFT", charBankFrame, "TOPRIGHT", 10, 0)
			
			-- Save this position to the profile for future use
			local anchor = warbandFrame.anchor
			if anchor then
				anchor:SaveSettings()
			end
		end
	end

	function warbandBank:PostClose()
		-- Warband bank doesn't need to close native bank frame
	end

	function warbandBank:Sort()
		PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
		-- Add warband bank sorting if available in future
	end

	function warbandBank:BankFrameGetRight()
		return 0
	end

end

--------------------------------------------------------------------------------
-- Helper for modules
--------------------------------------------------------------------------------

local hooks = {}

function addon:HookBagFrameCreation(target, callback)
	local hook = hooks[target]
	if not hook then
		local target, callback, seen = target, callback, {}
		hook = function(event, bag)
			if seen[bag] then return end
			seen[bag] = true
			local res, msg
			if type(callback) == "string" then
				res, msg = pcall(target[callback], target, bag)
			else
				res, msg = pcall(callback, bag)
			end
			if not res then
				geterrorhandler()(msg)
			end
		end
		hooks[target] = hook
	end
	local listen = false
	for index, bag in pairs(bags) do
		if bag:HasFrame() then
			hook("HookBagFrameCreation", bag)
		else
			listen = true
		end
	end
	if listen then
		target:RegisterMessage("AdiBags_BagFrameCreated", hook)
	end
end
