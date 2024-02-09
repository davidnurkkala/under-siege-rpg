local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local DialogueService = require(ServerScriptService.Server.Services.DialogueService)
local LobbySession = require(ServerScriptService.Server.Classes.LobbySession)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerFade = require(ServerScriptService.Server.Util.ServerFade)
local Signal = require(ReplicatedStorage.Packages.Signal)
local WorldService = require(ServerScriptService.Server.Services.WorldService)

local PlayerSlots: { [Player]: boolean } = {}

local GameService = {
	Priority = 0,
}

type GameService = typeof(GameService)

function GameService.PrepareBlocking(self: GameService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "GameService")

	Observers.observePlayer(function(player)
		local index = 1
		while PlayerSlots[index] do
			index += 1
		end

		PlayerSlots[index] = true

		player:SetAttribute("UniqueIndex", index)

		return function()
			PlayerSlots[index] = nil
		end
	end)

	self.Comm:BindFunction("Play", function(player)
		local done = Signal.new()

		LobbySession.promised(player)
			:andThen(function()
				return DataService:IsFirstSession(player)
			end)
			:andThen(function(isFirstSession)
				--isFirstSession = true
				if isFirstSession then
					ServerFade(player, nil, function()
						DialogueService:StartDialogue(player, "OpeningCutscene")
						done:Fire()
					end)
				else
					WorldService:GetCurrentWorld(player):andThen(function(worldId)
						WorldService:TeleportToWorld(player, worldId, function()
							done:Fire()
						end)
					end)
				end
			end)

		done:Wait()
		return true
	end)
end

return GameService
