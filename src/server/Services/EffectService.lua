local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)

local EffectService = {
	Priority = 0,
}

local function serverImpls(callback, ...)
	return Promise.all(Sift.Array.map(Sift.Array.slice({ ... }, 1, -1), function(impl)
		local name, args, retVal = impl()
		callback(name, args)
		return retVal
	end))
end

type ServerImpl = () -> (string, { [string]: any }, any)

type EffectService = typeof(EffectService)

function EffectService.PrepareBlocking(self: EffectService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "EffectService")
	self.EffectRequested = self.Comm:CreateSignal("EffectRequested")
end

function EffectService.All(self: EffectService, ...)
	return serverImpls(function(name, args)
		self.EffectRequested:FireAll(name, args)
	end, ...)
end

function EffectService.ForBattle(self: EffectService, battle, ...)
	local BattleService = require(ServerScriptService.Server.Services.BattleService) :: any
	return self:EffectPlayers(BattleService:GetPlayersFromBattle(battle), ...)
end

function EffectService.Effect(self: EffectService, player: Player, ...)
	return serverImpls(function(name, args)
		self.EffectRequested:Fire(player, name, args)
	end, ...)
end

function EffectService.EffectPlayers(self: EffectService, players: { Player }, ...)
	local args = { ... }

	return Promise.all(Sift.Array.map(players, function(player)
		return self:Effect(player, unpack(args))
	end))
end

return EffectService
