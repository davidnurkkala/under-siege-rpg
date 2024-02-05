local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectUpdate = require(ReplicatedStorage.Shared.Effects.EffectUpdate)
local EffectWipeTransition = require(ReplicatedStorage.Shared.Effects.EffectWipeTransition)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(players: Player | { Player }, args: { [string]: any }?, promiseFunc: () -> any)
	local func = if typeof(players) == "table"
		then function(...)
			return EffectService:EffectPlayers(...)
		end
		else function(...)
			return EffectService:Effect(...)
		end

	local guid = Guid()

	return func(players, EffectWipeTransition(Sift.Dictionary.merge(args or {}, { Guid = guid }))):andThenCall(promiseFunc):finally(function()
		func(players, EffectUpdate({ Guid = guid }))
	end)
end
