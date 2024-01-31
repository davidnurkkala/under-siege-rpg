local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battle = require(ServerScriptService.Server.Classes.Battle)
local LobbySession = require(ServerScriptService.Server.Classes.LobbySession)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Promise = require(ReplicatedStorage.Packages.Promise)
local ServerFade = require(ServerScriptService.Server.Util.ServerFade)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)

local BattleHelper = {}

function BattleHelper.FadeToBattle(player, battlerId, defaultCFrame)
	local session = LobbySessions.Get(player)
	if not session then return end

	local cframe = TryNow(function()
		return player.Character.PrimaryPart.CFrame
	end, defaultCFrame or CFrame.new())

	session:Destroy()

	local function restoreSession()
		return LobbySession.promised(player):andThenCall(Promise.delay, 0.5):andThen(function()
			TryNow(function()
				player.Character.PrimaryPart.CFrame = cframe
			end)
		end)
	end

	return ServerFade(player, nil, function()
			return Battle.fromPlayerVersusBattler(player, battlerId):catch(warn)
		end)
		:andThen(function(battle)
			return Promise.fromEvent(battle.Finished):andThenReturn(battle)
		end)
		:andThen(function(battle)
			local playerWon = battle:GetVictor().CharModel == player.Character

			return ServerFade(player, nil, function()
				battle:Destroy()

				return restoreSession():andThenReturn(playerWon)
			end)
		end)
		:catch(function()
			restoreSession()
			return false
		end)
end

return BattleHelper
