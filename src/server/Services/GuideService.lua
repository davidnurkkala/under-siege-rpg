local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local BeInWorld = require(ServerScriptService.Server.Badger.Conditions.BeInWorld)
local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local DefeatBattler = require(ServerScriptService.Server.Badger.Conditions.DefeatBattler)
local HaveCurrency = require(ServerScriptService.Server.Badger.Conditions.HaveCurrency)
local HaveWeapon = require(ServerScriptService.Server.Badger.Conditions.HaveWeapon)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WorldDefs = require(ReplicatedStorage.Shared.Defs.WorldDefs)

local GuideService = {
	Priority = 0,
}

type GuideService = typeof(GuideService)

local function tutorialCondition(player) end

function GuideService.PrepareBlocking(self: GuideService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "GuideService")
	self.StatusRemote = self.Comm:CreateProperty("Status")
	self.GuiGuideRemote = self.Comm:CreateProperty("GuiGuide", {})
end

return GuideService
