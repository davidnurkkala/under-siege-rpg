local ServerScriptService = game:GetService("ServerScriptService")

local Goon = require(ServerScriptService.Server.Classes.Goon)

local TagLight = {}
TagLight.__index = TagLight

export type TagLight = typeof(setmetatable({} :: {
	Connection: any,
}, TagLight))

function TagLight.new(goon): TagLight
	local self: TagLight = setmetatable({}, TagLight)

	self.Connection = goon.WillDealDamage:Connect(function(damage)
		if damage.Target:HasTag("Armored") then
			damage.Amount *= 1.5
		end
	end)

	return self
end

function TagLight.Destroy(self: TagLight)
	self.Connection:Disconnect()
end

return TagLight
