local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Lapis = require(ServerScriptService.ServerPackages.Lapis)
local Observers = require(ReplicatedStorage.Packages.Observers)

local DataService = {
	Priority = -1024,
}

type DataService = typeof(DataService)

function DataService.PrepareBlocking(self: DataService)
	self.Collection = Lapis.createCollection("LevelService", {
		validate = function()
			return true
		end,
		defaultData = {
			Level = 0,
			Experience = 0,
			PrestigeCount = 0,
		},
	})

	Observers.observePlayer(function(player: Player) end)
end

function DataService.Get(self: DataService, player: Player)
	return self.Collection:load(player.UserId)
end
