local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DialogueService = require(ServerScriptService.Server.Services.DialogueService)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WorldService = require(ServerScriptService.Server.Services.WorldService)

local ChaserBattlers = {
	TestChaserBattler = {
		Speed = 24,
		BattlerId = "Peasant",
		Animations = {
			Idle = "ShopkeeperIdle",
			Walk = "GenericRun",
		},
		OnDefeat = function(player)
			DialogueService:OneOff(player, { Text = "You lost the battle, loser!!!" })
			return WorldService:TeleportToWorldRaw(player, "World1")
		end,
	},
}

return Sift.Dictionary.map(ChaserBattlers, function(def, id)
	return Sift.Dictionary.merge(def, {
		Id = id,
	})
end)
