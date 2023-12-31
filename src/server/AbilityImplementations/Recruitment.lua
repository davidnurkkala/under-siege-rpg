local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Goon = require(ServerScriptService.Server.Classes.Goon)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(def, level, battler, battle)
	return Promise.new(function(resolve)
		local remaining = level
		local targets = battle:TargetFarToClose({
			Battler = battler,
			Filter = battle:AllyFilter(battler.TeamId),
		})

		for _, target in targets do
			if not Goon.Is(target) then continue end
			if target.Def.Id ~= "Peasant" then continue end

			Goon.fromId({
				Id = "Recruit",
				Battle = battle,
				Battler = battler,
				Direction = target.Direction,
				Position = target.Position,
				TeamId = battler.TeamId,
				Level = target.Level,
			})

			target:Destroy()

			remaining -= 1
			if remaining <= 0 then break end
		end

		resolve()
	end)
end
