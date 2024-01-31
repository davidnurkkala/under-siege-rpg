local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityDefs = require(ReplicatedStorage.Shared.Defs.AbilityDefs)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Default = require(ReplicatedStorage.Shared.Util.Default)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local GoonPreview = require(ReplicatedStorage.Shared.React.Goons.GoonPreview)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local React = require(ReplicatedStorage.Packages.React)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponPreview = require(ReplicatedStorage.Shared.React.Weapons.WeaponPreview)
local WeaponTypeDefs = require(ReplicatedStorage.Shared.Defs.WeaponTypeDefs)
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
	elseif reward.Type == "Weapon" then
		return React.createElement(WeaponPreview, {
			WeaponId = reward.WeaponId,
		})
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
	elseif reward.Type == "Weapon" then
		return ColorDefs.White
	end

	return ColorDefs.PaleBlue
end

function RewardDisplayHelper.GetRewardDetails(reward: any)
	assert(typeof(reward) == "table", `Expected table`)

	local text

	if reward.Type == "Currency" then
		text = CurrencyDefs[reward.CurrencyType].Description
	elseif reward.Type == "Card" then
		text = CardHelper.GetDescription(reward.CardId, 1)
	elseif reward.Type == "Weapon" then
		local def = WeaponDefs[reward.WeaponId]
		local typeDef = WeaponTypeDefs[def.WeaponType]
		text = `{def.Description}\n\n{typeDef.Description}\n\nWeapons are mostly cosmetic and all have roughly the same damage per second.`
	else
		error(`Unrecognized reward type {reward.Type}`)
	end

	return `{RewardDisplayHelper.GetRewardText(reward, true)}\n\n{text}`
end

function RewardDisplayHelper.GetRewardText(reward: any, excitementDisabled: boolean?)
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
			return `{if excitementDisabled then "" else "New ability! "}{AbilityDefs[cardDef.AbilityId].Name}`
		elseif cardDef.Type == "Goon" then
			return `{if excitementDisabled then "" else "New soldier! "}{GoonDefs[cardDef.GoonId].Name}`
		else
			error(`Unrecognized card type {cardDef.Type}`)
		end
	elseif reward.Type == "Weapon" then
		local weaponDef = WeaponDefs[reward.WeaponId]
		return `{if excitementDisabled then "" else "New weapon! "}{weaponDef.Name}`
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

return RewardDisplayHelper
