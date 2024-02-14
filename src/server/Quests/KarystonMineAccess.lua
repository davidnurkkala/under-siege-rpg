local ServerScriptService = game:GetService("ServerScriptService")

local FinishBattle = require(ServerScriptService.Server.Badger.Conditions.FinishBattle)
local StagedQuest = require(ServerScriptService.Server.Badger.Conditions.StagedQuest)
local UseInBattleAttack = require(ServerScriptService.Server.Badger.Conditions.UseInBattleAttack)

return {
	Name = "The Karyston Mine",
	Summary = "The count of Karyston owns the mine. If I could get access, the ore within could be useful for upgrading my army.",
	Condition = function(player)
		return StagedQuest(player, script.Name, {
			{
				Name = "DefeatNoble",
				Condition = FinishBattle(player, "Noble"):without(UseInBattleAttack(player, 1)):described("Defeat the noble without attacking."),
			},
		}, "Speak to the Noble about his mine.")
	end,
	OnCompleted = function() end,
}
