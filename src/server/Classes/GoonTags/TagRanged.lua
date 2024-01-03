local ServerScriptService = game:GetService("ServerScriptService")

local Goon = require(ServerScriptService.Server.Classes.Goon)
local TagRanged = {}
TagRanged.__index = TagRanged

export type TagRanged = typeof(setmetatable({} :: {
	Connection: any,
}, TagRanged))

function TagRanged.new(goon): TagRanged
	local self: TagRanged = setmetatable({}, TagRanged)

	self.Connection = goon.WillDealDamage:Connect(function(damage)
		if damage.Target:HasTag("Light") then
			damage.Amount *= 1.1
		end
	end)

	return self
end

function TagRanged.Destroy(self: TagRanged)
	self.Connection:Destroy()
end

return TagRanged
