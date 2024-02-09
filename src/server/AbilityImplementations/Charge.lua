local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Stat = require(ServerScriptService.Server.Classes.Stat)

return function(def, level, battler, battle)
	local duration = def.Duration(level)
	local amount = def.Amount(level)

	for _, target in battle:TargetRadius({ Position = battler.Position, Radius = 0.5, Filter = battle:AllyGoonsFilter(battler.TeamId) }) do
		local speed: Stat.Stat = target.Stats.Speed
		if not speed then continue end

		task.delay(
			duration,
			speed:Modify("Percent", function(value)
				return value + amount
			end)
		)
	end

	battler.Animator:Play("MagicCastQuick", 0)

	return Promise.resolve()
end
