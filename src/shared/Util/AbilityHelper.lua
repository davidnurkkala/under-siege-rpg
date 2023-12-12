local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local AbilityDefs = require(ReplicatedStorage.Shared.Defs.AbilityDefs)

local AbilityHelper = {}

function AbilityHelper.GetAbility(abilityId: string)
	return AbilityDefs[abilityId]
end

function AbilityHelper.GetImplementation(abilityId: string)
	assert(RunService:IsServer(), `Implementation can only be called on the server`)

	return function(...)
		require(ServerScriptService.Server.AbilityImplementations[abilityId])(AbilityHelper.GetAbility(abilityId), ...)
	end
end

return AbilityHelper
