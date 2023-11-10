local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
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

function GameService.Start(self: GameService) end

return GameService
