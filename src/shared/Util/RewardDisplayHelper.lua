local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityDefs = require(ReplicatedStorage.Shared.Defs.AbilityDefs)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local GoonPreview = require(ReplicatedStorage.Shared.React.Goons.GoonPreview)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local React = require(ReplicatedStorage.Packages.React)
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

function RewardDisplayHelper.CreateRewardElement(reward: any)
	if reward.Type == "Currency" then
		return React.createElement(Image, {
			Image = RewardDisplayHelper.GetRewardImage(reward),
		})
	elseif reward.Type == "Card" then
		local cardDef = CardDefs[reward.CardId]
		if cardDef.Type == "Ability" then
			return React.createElement(Image, {
				Image = AbilityDefs[cardDef.AbilityId].Image,
			})
		elseif cardDef.Type == "Goon" then
			return React.createElement(GoonPreview, {
				GoonId = cardDef.GoonId,
			})
		else
			error(`Unimplemented card type {cardDef.Type}`)
		end
	else
		error(`Unimplemented reward type {reward.Type}`)
	end
end

function RewardDisplayHelper.GetRewardColor(reward: any)
	if reward.Type == "Currency" then
		return CurrencyDefs[reward.CurrencyType].Colors.Primary
	elseif reward.Type == "Card" then
		local cardDef = CardDefs[reward.CardId]
		if cardDef.Type == "Ability" then
			return ColorDefs.LightBlue
		elseif cardDef.Type == "Goon" then
			return ColorDefs.PaleGreen
		end
	end

	return ColorDefs.PaleBlue
end

function RewardDisplayHelper.GetRewardText(reward: any)
	assert(typeof(reward) == "table", `Expected table`)

	if reward.Type == "Currency" then
		return `{FormatBigNumber(reward.Amount)} {CurrencyDefs[reward.CurrencyType].Name}`
	elseif reward.Type == "Boost" then
		if reward.Boost.Type == "Currency" then
			local minutes = math.floor(reward.Boost.Time / 60)
			return `{reward.Boost.Multiplier}x {minutes}m`
		else
			error(`Unrecognized boost type {reward.Boost.Type}`)
		end
	elseif reward.Type == "Card" then
		local cardDef = CardDefs[reward.CardId]
		if cardDef.Type == "Ability" then
			return `New ability! {AbilityDefs[cardDef.AbilityId].Name}`
		elseif cardDef.Type == "Goon" then
			return `New soldier! {GoonDefs[cardDef.GoonId].Name}`
		else
			error(`Unrecognized card type {cardDef.Type}`)
		end
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

return RewardDisplayHelper
