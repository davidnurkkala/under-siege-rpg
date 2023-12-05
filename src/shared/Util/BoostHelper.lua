local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local BoostHelper = {}

function BoostHelper.GetMultiplier(boosts, predicate)
	return Sift.Array.reduce(Sift.Array.filter(boosts, predicate), function(mult, boost)
		return mult * boost.Multiplier
	end, 1)
end

function BoostHelper.GetTime(boosts, predicate)
	local t = Sift.Array.reduce(Sift.Array.filter(boosts, predicate), function(t, boost)
		return math.min(t, boost.Time)
	end, math.huge)

	if t == math.huge then
		return 0
	else
		return t
	end
end

return BoostHelper
