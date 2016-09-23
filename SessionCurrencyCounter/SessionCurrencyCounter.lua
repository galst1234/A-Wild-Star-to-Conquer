-----------------------------------------------------------------------------------------------
-- Client Lua Script for SessionCurrencyCounter
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- SessionCurrencyCounter Module Definition
-----------------------------------------------------------------------------------------------
local SessionCurrencyCounter = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function SessionCurrencyCounter:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

	self.currentMoney = 0
	self.debug = false
	self.tOptions = {
		moveable = false,
		prevMoveable = false,
		debug = false
	}

    -- initialize variables here

    return o
end

function SessionCurrencyCounter:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- SessionCurrencyCounter OnLoad
-----------------------------------------------------------------------------------------------
function SessionCurrencyCounter:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("SessionCurrencyCounter.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- SessionCurrencyCounter OnDocLoaded
-----------------------------------------------------------------------------------------------
function SessionCurrencyCounter:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "SessionCurrencyCounterForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.\n"
				.. "Try reloadint the UI.")
			return
		end
		
	    self.wndMain:Show(false, true)
		
		self.wndCounter = Apollo.LoadForm(self.xmlDoc, "Counter", nil, self)
		if self.wndCounter == nil then
			Apollo.AddAddonErrorText(self, "Could not load the counter window for some reason\n"
				.. "Try reloadint the UI.")
			return
		end
		
		self.wndCounter:Show(true, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("CurrencyCounter", "OnSessionCurrencyCounterOn", self)

		self.timer = ApolloTimer.Create(5.0, true, "OnTimer", self)
		
		Apollo.RegisterEventHandler("ChannelUpdate_Loot", "RaiseMoneyCounter", self)
		
		Apollo.RegisterSlashCommand("curc_reset", "ResetMoneyCounter", self)
		Apollo.RegisterSlashCommand("curc_set", "SetMoneyCounter", self)

		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- SessionCurrencyCounter Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/CurrencyCounter"
function SessionCurrencyCounter:OnSessionCurrencyCounterOn()

	self.wndMain:Invoke() -- show the window
end

-- on timer
function SessionCurrencyCounter:OnTimer()
	if self.debug then
		Print(self.currentMoney)
	end
	-- Do your timer-related stuff here.
end

-- raise money; ChannelUpdate_Loot event handler
function SessionCurrencyCounter:RaiseMoneyCounter(eType, tEventArgs)
	if self.debug then Print("Received loot") end
	if eType == Item.CodeEnumLootItemType.Cash then
		if self.debug then Print("Received currency", tEventArgs.monNew:GetMoneyType()) end
		if tEventArgs.monNew:GetMoneyType() == Money.CodeEnumCurrencyType.Credits then
			if self.debug then Print("Received cash") end
			self.currentMoney = self.currentMoney + tEventArgs.monNew:GetAmount() -- Find the new money thing
			self.wndCounter:FindChild("CashWindow"):SetAmount(self.currentMoney, false)
		end
	end
end

-- Reset counter
function SessionCurrencyCounter:ResetMoneyCounter()
	if self.debug then Print("Reset counter") end
	self.currentMoney = 0
	self.wndCounter:FindChild("CashWindow"):SetAmount(self.currentMoney, true)
end

-- Set counter
function SessionCurrencyCounter:SetMoneyCounter(strCmd, strArgs)
	if self.debug then
		Print("Set recevied: " .. strArgs)
	end
end

function SessionCurrencyCounter:ApplySettings(owner)
	owner.wndCounter:SetStyle("Moveable", owner.tOptions.moveable)
	owner.debug = owner.tOptions.debug
	owner.tOptions.prevMoveable = owner.tOptions.moveable
end

-----------------------------------------------------------------------------------------------
-- SessionCurrencyCounterForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function SessionCurrencyCounter:OnOK()
	SessionCurrencyCounter:ApplySettings(self)
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function SessionCurrencyCounter:OnCancel()
	self.tOptions.debug = self.debug
	self.tOptions.moveable = self.tOptions.prevMoveable
	self.wndMain:FindChild("Moveable"):SetValue(self.tOptions.moveable) TODO: Set checkbox value
--	self.wndMain:FindChild("Debug"):SetData(self.debug)
	self.wndMain:Close() -- hide the window
end

-- when the Apply button is clicked
function SessionCurrencyCounter:OnApply( wndHandler, wndControl, eMouseButton )
	SessionCurrencyCounter:ApplySettings(self)
end

function SessionCurrencyCounter:MoveableChecked( wndHandler, wndControl, eMouseButton )
	--self.wndCounter:SetStyle("Moveable", true)
	self.tOptions.moveable = true
end

function SessionCurrencyCounter:MoveableUnchecked( wndHandler, wndControl, eMouseButton )
	--self.wndCounter:SetStyle("Moveable", false)
	self.tOptions.moveable = false
end

function SessionCurrencyCounter:ResetMoneyCounterButton( wndHandler, wndControl, eMouseButton )
	self:ResetMoneyCounter()
end

function SessionCurrencyCounter:DebugChecked( wndHandler, wndControl, eMouseButton )
	self.tOptions.debug = true
end

function SessionCurrencyCounter:DebugUnchecked( wndHandler, wndControl, eMouseButton )
	self.tOptions.debug = false
end

-----------------------------------------------------------------------------------------------
-- SessionCurrencyCounter Instance
-----------------------------------------------------------------------------------------------
local SessionCurrencyCounterInst = SessionCurrencyCounter:new()
SessionCurrencyCounterInst:Init()
