local ServerScriptService = game:GetService("ServerScriptService")

local BoostService = require(ServerScriptService.Server.Services.BoostService)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local RewardHelper = {}

function RewardHelper.GiveReward(player: Player, reward: any)
	assert(typeof(reward) == "table", `Expected reward to be a table.`)

	if reward.Type == "Currency" then
		return CurrencyService:AddCurrency(player, reward.CurrencyType, reward.Amount)
	elseif reward.Type == "Boost" then
		return BoostService:AddBoost(player, reward.Boost)
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

return RewardHelper
