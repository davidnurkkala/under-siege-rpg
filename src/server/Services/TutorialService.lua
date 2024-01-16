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

local TutorialService = {
	Priority = 0,
}

type TutorialService = typeof(TutorialService)

local function tutorialCondition(player)
	return Badger.sequence({
		Badger.onCompleted(DefeatBattler(player, "Peasant", 1), function()
			CurrencyService:AddCurrency(player, "Coins", 10)
		end):withState(function(condition)
			return {
				Instruction = "Battler",
				State = condition:getState(),
			}
		end),
	})
end

function TutorialService.PrepareBlocking(self: TutorialService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "TutorialService")
	self.StatusRemote = self.Comm:CreateProperty("Status")

	Observers.observePlayer(function(player)
		local condition = nil

		DataService:GetSaveFile(player):andThen(function(saveFile)
			local tutorialData = saveFile:Get("TutorialData")
			if tutorialData == "Complete" then return end

			-- create the condition
			condition = tutorialCondition(player)

			-- save on change
			condition = Badger.onProcess(condition, function(processed)
				local state = processed:getState()
				local changed = not Sift.Dictionary.equalsDeep(state, self.StatusRemote:GetFor(player))
				if changed then self.StatusRemote:SetFor(player, processed:getState()) end

				saveFile:Set("TutorialData", processed:save())
			end)

			-- save on complete
			condition = Badger.start(Badger.onCompleted(condition, function(completed)
				Badger.stop(completed)
				saveFile:Set("TutorialData", "Complete")
				condition = nil
			end))

			-- load data if it exists
			if tutorialData ~= nil then
				condition:load(tutorialData)
				self.StatusRemote:SetFor(player, condition:getState())
			end
		end)

		-- stop the condition if the player leaves
		return function()
			if condition then Badger.stop(condition) end
		end
	end)
end

return TutorialService
