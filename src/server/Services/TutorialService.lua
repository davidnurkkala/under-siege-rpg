local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local BeInWorld = require(ServerScriptService.Server.Badger.Conditions.BeInWorld)
local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local DefeatBattler = require(ServerScriptService.Server.Badger.Conditions.DefeatBattler)
local HaveCurrency = require(ServerScriptService.Server.Badger.Conditions.HaveCurrency)
local HaveWeapon = require(ServerScriptService.Server.Badger.Conditions.HaveWeapon)
local Observers = require(ReplicatedStorage.Packages.Observers)
local RollCardGacha = require(ServerScriptService.Server.Badger.Conditions.RollCardGacha)
local RollPetGacha = require(ServerScriptService.Server.Badger.Conditions.RollPetGacha)
local Sift = require(ReplicatedStorage.Packages.Sift)

local TutorialService = {
	Priority = 0,
}

type TutorialService = typeof(TutorialService)

local function tutorialCondition(player)
	return Badger.sequence({
		DefeatBattler(player, "Peasant", 1):withState(function(condition)
			return {
				Instruction = "Battler",
				State = condition:getState(),
			}
		end),
		HaveCurrency(player, "Primary", 100):withState(function(condition)
			return {
				Instruction = "TrainingDummy",
				State = condition:getState(),
			}
		end),
		HaveWeapon(player, "HuntersBow"):withState(function(condition)
			return {
				Instruction = "WeaponShop",
				State = condition:getState(),
			}
		end),
		HaveCurrency(player, "Primary", 200):withState(function(condition)
			return {
				Instruction = "TrainingDummy",
				State = condition:getState(),
			}
		end),
		RollCardGacha(player, "World1Goons", 1):withState(function(condition)
			return {
				Instruction = "CardGacha",
				State = condition:getState(),
			}
		end),
		DefeatBattler(player, "Peasant", 2):withState(function(condition)
			return {
				Instruction = "Battler",
				State = condition:getState(),
			}
		end),
		RollPetGacha(player, "World1Pets", 1):withState(function(condition)
			return {
				Instruction = "PetGacha",
				State = condition:getState(),
			}
		end),
		HaveCurrency(player, "Primary", 100000):withState(function(condition)
			return {
				Instruction = "TrainLongTerm",
				State = condition:getState(),
			}
		end),
		DefeatBattler(player, "King", 1):withState(function(condition)
			return {
				Instruction = "Battler",
				State = condition:getState(),
			}
		end),
		HaveCurrency(player, "Secondary", 1000):withState(function(condition)
			return {
				Instruction = "Gold",
				State = condition:getState(),
			}
		end),
		BeInWorld(player, "World2"):withState(function(condition)
			return {
				Instruction = "Portal",
				State = condition:getState(),
			}
		end),

		-- beat viking world
		HaveCurrency(player, "Primary", 750000):withState(function(condition)
			return {
				Instruction = "TrainLongTerm",
				State = condition:getState(),
			}
		end),
		DefeatBattler(player, "VikingKing", 1):withState(function(condition)
			return {
				Instruction = "Battler",
				State = condition:getState(),
			}
		end),
		HaveCurrency(player, "Secondary", 10000):withState(function(condition)
			return {
				Instruction = "Gold",
				State = condition:getState(),
			}
		end),
		BeInWorld(player, "World3"):withState(function(condition)
			return {
				Instruction = "Portal",
				State = condition:getState(),
			}
		end),

		-- beat elf world
		HaveCurrency(player, "Primary", 10000000):withState(function(condition)
			return {
				Instruction = "TrainLongTerm",
				State = condition:getState(),
			}
		end),
		DefeatBattler(player, "ElfKing", 1):withState(function(condition)
			return {
				Instruction = "Battler",
				State = condition:getState(),
			}
		end),
		HaveCurrency(player, "Secondary", 50000):withState(function(condition)
			return {
				Instruction = "Gold",
				State = condition:getState(),
			}
		end),
		BeInWorld(player, "World4"):withState(function(condition)
			return {
				Instruction = "Portal",
				State = condition:getState(),
			}
		end),

		-- beat orc world
		HaveCurrency(player, "Primary", 100000000):withState(function(condition)
			return {
				Instruction = "TrainLongTerm",
				State = condition:getState(),
			}
		end),
		DefeatBattler(player, "OrcGeneral", 1):withState(function(condition)
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
