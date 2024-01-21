local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local GoonTagDefs = require(ReplicatedStorage.Shared.Defs.GoonTagDefs)
local CardHelper = {}

function CardHelper.GetName(id: string)
	local cardDef = CardDefs[id]
	if not cardDef then return "" end

	if cardDef.Type == "Goon" then
		return GoonDefs[cardDef.GoonId].Name
	elseif cardDef.Type == "Ability" then
		local ability = AbilityHelper.GetAbility(cardDef.AbilityId)
		return ability.Name
	else
		error("Unsupported type")
	end
end

function CardHelper.GetDescription(id: string, level: number)
	local cardDef = CardDefs[id]

	if cardDef.Type == "Goon" then
		local function get(key)
			return CardHelper.GetGoonStatRaw(id, level, key)
		end

		local goonDef = GoonDefs[cardDef.GoonId]
		local description = goonDef.Description
		description ..= `\n`
		description ..= `\n{get("AttackRate") // 0.1 / 10} attacks per second`
		description ..= `\nRange: {get("Range") // 0.01} units`
		description ..= `\nSpeed: {get("Speed") // 0.01} units/second`
		description ..= `\nSize: {get("Size") // 0.01} units`

		if goonDef.Tags then
			description ..= `\n`
			for _, tagId in goonDef.Tags do
				local tagDef = GoonTagDefs[tagId]
				description ..= `\n{tagDef.Name} - {tagDef.Description}`
			end
		end

		return description
	elseif cardDef.Type == "Ability" then
		local ability = AbilityHelper.GetAbility(cardDef.AbilityId)

		local description = ability.Description
		if typeof(description) == "function" then description = description(ability, level) end

		return description
	else
		error(`Unimplemented card type {cardDef.Type}`)
	end
end

function CardHelper.IsGoon(cardId: string)
	return CardDefs[cardId].Type == "Goon"
end

function CardHelper.IsAbility(cardId: string)
	return CardDefs[cardId].Type == "Ability"
end

function CardHelper.GetGoonStatRaw(cardId: string, level: number?, key: string)
	local cardDef = CardDefs[cardId]
	assert(cardDef, `No card def found for card id {cardId}`)
	assert(cardDef.Type == "Goon", `Requested card is not a goon`)

	local def = GoonDefs[cardDef.GoonId]

	if level == nil then level = 1 end

	local value = def.Stats[key]

	if typeof(value) == "function" then value = value(level) end

	return value
end

function CardHelper.HasUpgrade(cardId: string, level: number)
	return CardHelper.GetUpgrade(cardId, level) ~= nil
end

function CardHelper.GetUpgrade(cardId: string, level: number)
	local cardDef = CardDefs[cardId]
	if not cardDef.Upgrades then return nil end
	return cardDef.Upgrades[level]
end

function CardHelper.GetGoonStat(cardId: string, level: number?, key: string)
	return CardHelper.GetGoonStatRaw(cardId, level, key) // 0.1 / 10
end

return CardHelper
