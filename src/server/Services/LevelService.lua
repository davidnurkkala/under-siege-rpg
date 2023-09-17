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
		saveFile:Update("Experience", function(oldExperience)
			return oldExperience + amount
		end)
	end)
end

return LevelService
