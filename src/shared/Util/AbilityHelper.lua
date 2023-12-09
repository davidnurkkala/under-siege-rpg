local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Sift = require(ReplicatedStorage.Packages.Sift)

local AbilityHelper = {}

local AbilitiesById = Sift.Dictionary.map(ReplicatedStorage.Shared.Abilities:GetChildren(), function(moduleScript)
	return require(moduleScript), moduleScript.Name
end)

function AbilityHelper.GetAbility(abilityId: string)
	return AbilitiesById[abilityId]
end

function AbilityHelper.GetImplementation(abilityId: string)
	assert(RunService:IsServer(), `Implementation can only be called on the server`)

	return function(...)
		require(ServerScriptService.Server.AbilityImplementations[abilityId])(AbilityHelper.GetAbility(abilityId), ...)
	end
end

return AbilityHelper
