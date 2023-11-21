local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local RewardDisplayHelper = {}

function RewardDisplayHelper.GetRewardImage(reward: any)
	assert(typeof(reward) == "table", `Expected table`)

	if reward.Type == "Currency" then
		return CurrencyDefs[reward.CurrencyType].Image
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

function RewardDisplayHelper.GetRewardText(reward: any)
	assert(typeof(reward) == "table", `Expected table`)

	if reward.Type == "Currency" then
		return FormatBigNumber(reward.Amount)
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

return RewardDisplayHelper
