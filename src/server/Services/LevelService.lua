local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Lapis = require(ServerScriptService.ServerPackages.Lapis)
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
		local promise = self.Collection:load(player.UserId):andThen(function(document)
			self.DocumentsByPlayer[player] = document

			local data = document:read()
			self.LevelRemote:SetFor(player, data.Level)
			self.ExperienceRemote:SetFor(player, data.Experience)
			self.PrestigeCountRemote:SetFor(player, data.PrestigeCount)
		end)

		return function()
			promise:cancel()

			if self.DocumentsByPlayer[player] then
				self.DocumentsByPlayer[player]:close()
				self.DocumentsByPlayer[player] = nil
			end
		end
	end)
end

function LevelService.Start(self: LevelService) end

return LevelService
