local ServerScriptService = game:GetService("ServerScriptService")

local Battler = require(ServerScriptService.Server.Classes.Battler)
local Goon = require(ServerScriptService.Server.Classes.Goon)
local TagArmored = {}
TagArmored.__index = TagArmored

export type TagArmored = typeof(setmetatable(
	{} :: {
		Connection: any,
	},
	TagArmored
))

function TagArmored.new(goon): TagArmored
	local self: TagArmored = setmetatable({}, TagArmored)

	self.Connection = goon.WillTakeDamage:Connect(function(damage)
		if damage.Source:HasTag("Ranged") then
			damage.Amount *= 0.33333
		end
	end)

	return self
end

function TagArmored.Destroy(self: TagArmored)
	self.Connection:Disconnect()
end

return TagArmored
