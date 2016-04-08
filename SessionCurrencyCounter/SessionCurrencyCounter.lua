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
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("CurrencyCounter", "OnSessionCurrencyCounterOn", self)

		self.timer = ApolloTimer.Create(5.0, true, "OnTimer", self)
		
		Apollo.RegisterEventHandler("monLoot", "RaiseMoneyCounter", self)

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
	Print(self.currentMoney)
	-- Do your timer-related stuff here.
end

-- raise money; monLoot event handler
function SessionCurrencyCounter:RaiseMoneyCounter(eType, tEventArgs)
	self.currentMoney = self.currentMoney + tEventArgs.monNew:GetAmount() -- Find the new money thing
end

-----------------------------------------------------------------------------------------------
-- SessionCurrencyCounterForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function SessionCurrencyCounter:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function SessionCurrencyCounter:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- SessionCurrencyCounter Instance
-----------------------------------------------------------------------------------------------
local SessionCurrencyCounterInst = SessionCurrencyCounter:new()
SessionCurrencyCounterInst:Init()
