local PrestigeHelper = {}

function PrestigeHelper.GetCost(prestige: number)
	local a = 1.5 * (prestige - 1)
	local b = 1.025 ^ prestige
	return math.floor(1e6 * a * b)
end

function PrestigeHelper.GetBoost(points: number)
	return 1 + (0.2 * points)
end

return PrestigeHelper
