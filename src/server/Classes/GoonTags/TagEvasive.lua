local ServerScriptService = game:GetService("ServerScriptService")

local Goon = require(ServerScriptService.Server.Classes.Goon)
local TagEvasive = {}
TagEvasive.__index = TagEvasive

export type TagEvasive = typeof(setmetatable({} :: {
	Connection: any,
}, TagEvasive))

function TagEvasive.new(goon): TagEvasive
	local self: TagEvasive = setmetatable({}, TagEvasive)

	self.Connection = goon.WillTakeDamage:Connect(function(damage)
		if damage.Source:HasTag("Ranged") then
			if math.random(1, 2) == 1 then damage:BeDodged() end
		end
	end)

	return self
end

function TagEvasive.Destroy(self: TagEvasive)
	self.Connection:Disconnect()
end

return TagEvasive
