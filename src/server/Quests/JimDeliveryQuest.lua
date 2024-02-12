local ServerScriptService = game:GetService("ServerScriptService")

local AdvanceQuest = require(ServerScriptService.Server.Badger.Conditions.AdvanceQuest)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local StagedQuest = require(ServerScriptService.Server.Badger.Conditions.StagedQuest)

return {
	Name = "Jim's Missing Shipment",
	Condition = function(player)
		return StagedQuest(player, script.Name, {
			{
				Name = "TalkToHolden",
				Condition = AdvanceQuest(player, script.Name),
			},
			{
				Name = "DefeatRoyce",
				Condition = AdvanceQuest(player, script.Name),
			},
			{
				Name = "ReturnToJim",
				Condition = AdvanceQuest(player, script.Name),
			},
		})
	end,
	OnCompleted = function(player)
		CurrencyService:AddCurrency(player, "Coins", 6000)
	end,
}
