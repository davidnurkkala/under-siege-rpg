local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local DefeatBattler = require(ServerScriptService.Server.Badger.Conditions.DefeatBattler)

return {
	Name = "Put Down the Rebellion",
	Condition = function(player)
		return Badger.withDescription(DefeatBattler(player, "RebelLeader", 5), function(condition)
			local state = condition:getState()
			return `Battle the Rebel Leader:\n{state.victories} / {state.requirement} wins`
		end)
	end,
	OnCompleted = function() end,
}
