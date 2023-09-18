local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)

local LevelService = {
	Priority = 0,
	DocumentsByPlayer = {},
}

type LevelService = typeof(LevelService)

local function getMaxLevel(prestigeCount: number): number
	return 100 + prestigeCount * 10
end

local function getRequiredExperienceAtLevel(level: number): number
	return level * 25
end

function LevelService.PrepareBlocking(self: LevelService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "LevelService")
	self.LevelRemote = self.Comm:CreateProperty("Level", 0)
	self.ExperienceRemote = self.Comm:CreateProperty("Experience", 0)
	self.PrestigeCountRemote = self.Comm:CreateProperty("PrestigeCount", 0)

	Observers.observePlayer(function(player)
		local promise = DataService:GetSaveFile(player):andThen(function(saveFile)
			saveFile:Observe("Level", function(level)
				self.LevelRemote:SetFor(player, level)
			end)

			saveFile:Observe("Experience", function(experience)
				self.ExperienceRemote:SetFor(player, experience)
			end)

			saveFile:Observe("PrestigeCount", function(prestigeCount)
				self.PrestigeCountRemote:SetFor(player, prestigeCount)
			end)
		end)

		return function()
			promise:cancel()
		end
	end)
end

function LevelService.Start(_self: LevelService) end

function LevelService.AddExperience(_self: LevelService, player: Player, amount: number)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local maxLevel = getMaxLevel(saveFile:Get("PrestigeCount"))
		if saveFile:Get("Level") >= maxLevel then return end

		local newExperience = saveFile:Get("Experience") + amount

		repeat
			local level = saveFile:Get("Level")
			if level >= maxLevel then
				newExperience = 0
				break
			end

			local req = getRequiredExperienceAtLevel(level)
			local leveledUp = newExperience >= req
			if leveledUp then
				newExperience -= req
				saveFile:Set("Level", level + 1)
			end
		until not leveledUp

		saveFile:Set("Experience", newExperience)
	end)
end

return LevelService
