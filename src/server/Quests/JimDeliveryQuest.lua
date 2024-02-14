local ServerScriptService = game:GetService("ServerScriptService")

local AdvanceQuest = require(ServerScriptService.Server.Badger.Conditions.AdvanceQuest)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local StagedQuest = require(ServerScriptService.Server.Badger.Conditions.StagedQuest)

return {
	Name = "Jim's Missing Shipment",
	Summary = "Jim the merchant is expecting a shipment from Bilmen. He asked me to check up on it, and will pay me if I can bring it to him.",
	Condition = function(player)
		return StagedQuest(player, script.Name, {
			{
				Name = "TalkToHolden",
				Condition = AdvanceQuest(player, script.Name):described("Go to the mountain village of Bilmen and speak to Holden about Jim's shipment."),
			},
			{
				Name = "DefeatRoyce",
				Condition = AdvanceQuest(player, script.Name):described("Find the bandit named Royce and get Jim's shipment back from him."),
			},
			{
				Name = "ReturnToJim",
				Condition = AdvanceQuest(player, script.Name):described("Return to Jim in Karyston and give him his shipment for a reward."),
			},
		})
	end,
	OnCompleted = function(player)
		CurrencyService:AddCurrency(player, "Coins", 6000)
	end,
}
