local CardHelper = {}

function CardHelper.CountToLevel(count: number)
	return math.floor(math.log(count, 2))
end

function CardHelper.GetNextUpgrade(count: number)
	return math.pow(CardHelper.CountToLevel(count) + 1, 2)
end

return CardHelper
