local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local CardHelper = {}

function CardHelper.GetDescription(id: string, count: number)
	local cardDef = CardDefs[id]

	if cardDef.Type == "Goon" then
		local function get(key)
			return CardHelper.GetGoonStatRaw(id, count, key)
		end

		local goonDef = GoonDefs[cardDef.GoonId]
		local description = goonDef.Description
		description ..= `\n`
		description ..= `\n{get("AttackRate") // 0.1 / 10} attacks per second`
		description ..= `\nRange: {get("Range") // 0.01} units`
		description ..= `\nSpeed: {get("Speed") // 0.01} units/second`
		description ..= `\nSize: {get("Size") // 0.01} units`

		return description
	elseif cardDef.Type == "Ability" then
		local ability = AbilityHelper.GetAbility(cardDef.AbilityId)

		local description = ability.Description
		if typeof(description) == "function" then description = description(ability, CardHelper.CountToLevel(count)) end

		return description
	else
		error(`Unimplemented card type {cardDef.Type}`)
	end
end

function CardHelper.CountToLevel(count: number)
	return math.floor(math.log(count, 2)) + 1
end

function CardHelper.WasLevelUp(count: number)
	if count < 2 then return false end

	local _, frac = math.modf(math.log(count, 2))
	return frac == 0
end

function CardHelper.GetNextUpgrade(count: number)
	return math.pow(2, CardHelper.CountToLevel(count))
end

function CardHelper.GetGoonStatRaw(cardId: string, count: number?, key: string)
	local cardDef = CardDefs[cardId]
	assert(cardDef, `No card def found for card id {cardId}`)
	assert(cardDef.Type == "Goon", `Requested card is not a goon`)

	local def = GoonDefs[cardDef.GoonId]

	if count == nil then count = 1 end

	local value = def[key]

	if typeof(value) == "function" then
		local level = CardHelper.CountToLevel(count :: number)
		value = value(level)
	end

	return value
end

function CardHelper.GetGoonStat(cardId: string, count: number?, key: string)
	return CardHelper.GetGoonStatRaw(cardId, count, key) // 0.1 / 10
end

return CardHelper
