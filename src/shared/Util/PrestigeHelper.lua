local PrestigeHelper = {}

function PrestigeHelper.GetCost(prestige: number)
	return math.floor(1e6 * (1.5 ^ prestige))
end

function PrestigeHelper.GetBoost(points: number)
	return 1.2 ^ points
end

return PrestigeHelper
