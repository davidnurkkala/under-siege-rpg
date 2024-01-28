local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local FinishBattle = require(ServerScriptService.Server.Badger.Conditions.FinishBattle)
local UseInBattleAttack = require(ServerScriptService.Server.Badger.Conditions.UseInBattleAttack)

return {
	Name = "Defeat the Noble",
	Condition = function(player)
		return Badger.withDescription(Badger.without(FinishBattle(player, "Noble"), UseInBattleAttack(player, 1)), function()
			return `Defeat the Noble without attacking.`
		end)
	end,
	OnCompleted = function()
		print("BEAT HIM WITHOUT ATTACKING YEAAAAAAH")
	end,
}
