local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local LobbySession = require(ServerScriptService.Server.Classes.LobbySession)
local Observers = require(ReplicatedStorage.Packages.Observers)

local GameService = {
	Priority = 0,
}

type GameService = typeof(GameService)

function GameService.PrepareBlocking(self: GameService)
	Observers.observePlayer(function(player)
		LobbySession.promised(player)
	end)
end

return GameService
