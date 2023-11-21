local ServerScriptService = game:GetService("ServerScriptService")

local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local RewardHelper = {}

function RewardHelper.GiveReward(player: Player, reward: any)
	assert(typeof(reward) == "table", `Expected reward to be a table.`)

	if reward.Type == "Currency" then
		return CurrencyService:AddCurrency(player, reward.CurrencyType, reward.Amount)
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

return RewardHelper
