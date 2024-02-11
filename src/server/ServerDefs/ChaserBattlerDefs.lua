local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ConsequenceHelper = require(ServerScriptService.Server.Util.ConsequenceHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)

local ChaserBattlers = {
	BanditCaptain = {
		Speed = 24,
		BattlerId = "BanditCaptain",
		Animations = {
			Idle = "ShopkeeperIdle",
			Walk = "GenericRun",
		},
		OnDefeat = function(player)
			return ConsequenceHelper.Mugged(player, 0.05, function(amount)
				return `The bandit gang forced you to retreat, stealing {amount} coins from you.`
			end)
		end,
	},
	BanditKing = {
		Speed = 32,
		BattlerId = "BanditKing",
		Animations = {
			Idle = "ShopkeeperIdle",
			Walk = "GenericRun",
		},
		OnDefeat = function(player)
			return ConsequenceHelper.Mugged(player, 0.2, function(amount)
				return `The mighty bandit king captures you, ransoming you for {amount} coins and sending you off in disgrace.`
			end)
		end,
	},
}

return Sift.Dictionary.map(ChaserBattlers, function(def, id)
	return Sift.Dictionary.merge(def, {
		Id = id,
	})
end)
