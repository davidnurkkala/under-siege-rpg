local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)
local TagCharger = {}
TagCharger.__index = TagCharger

export type TagCharger = typeof(setmetatable({} :: {}, TagCharger))

function TagCharger.new(goon): TagCharger
	local self: TagCharger = setmetatable({}, TagCharger)

	local trove = Trove.new()
	trove:Add(goon:ModStat("Speed", "Percent", function(total)
		return total + 1
	end))
	trove:Connect(goon.Brain.WillAttack, function()
		trove:Clean()
	end)

	return self
end

function TagCharger.Destroy(self: TagCharger) end

return TagCharger
