local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battle = require(ServerScriptService.Server.Classes.Battle)
local LobbySession = require(ServerScriptService.Server.Classes.LobbySession)
local Observers = require(ReplicatedStorage.Packages.Observers)

local GameService = {
	Priority = 0,
}

type GameService = typeof(GameService)

function GameService.PrepareBlocking(self: GameService)
	Observers.observePlayer(function(player)
		LobbySession.promised(player):andThen(function(session)
			print("Session created!")

			task.delay(3, function()
				Battle.fromPlayerVersusComputer(player, "Noob", "Basic"):andThen(function(battle)
					print("Battle started!")
				end)
			end)
		end)
	end)
end

function GameService.Start(self: GameService) end

return GameService
