local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local CardHelper = {}

function CardHelper.CountToLevel(count: number)
	return math.floor(math.log(count, 2)) + 1
end

function CardHelper.GetNextUpgrade(count: number)
	return math.pow(2, CardHelper.CountToLevel(count))
end

function CardHelper.GetGoonStat(cardId: string, count: number?, key: string)
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

	return value // 0.1 / 10
end

return CardHelper
