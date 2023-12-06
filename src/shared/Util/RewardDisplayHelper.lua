local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local RewardDisplayHelper = {}

function RewardDisplayHelper.GetRewardImage(reward: any)
	assert(typeof(reward) == "table", `Expected table`)

	if reward.Type == "Currency" then
		return CurrencyDefs[reward.CurrencyType].Image
	elseif reward.Type == "Boost" then
		if reward.Boost.Type == "Currency" then
			return CurrencyDefs[reward.Boost.CurrencyType].Image
		else
			error(`Unrecognized boost type {reward.Boost.Type}`)
		end
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

function RewardDisplayHelper.GetRewardText(reward: any)
	assert(typeof(reward) == "table", `Expected table`)

	if reward.Type == "Currency" then
		return FormatBigNumber(reward.Amount)
	elseif reward.Type == "Boost" then
		if reward.Boost.Type == "Currency" then
			local minutes = math.floor(reward.Boost.Time / 60)
			return `{reward.Boost.Multiplier}x {minutes}m`
		else
			error(`Unrecognized boost type {reward.Boost.Type}`)
		end
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

return RewardDisplayHelper
