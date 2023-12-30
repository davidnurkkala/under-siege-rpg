local PrestigeHelper = {}

function PrestigeHelper.GetCost(prestige: number)
	local constant = 250000
	local linear = 50000 * prestige
	local quadratic = 10000 * prestige ^ 2
	return constant + linear + quadratic
end

function PrestigeHelper.GetBoost(points: number)
	return 1 + (0.1 * points)
end

return PrestigeHelper
