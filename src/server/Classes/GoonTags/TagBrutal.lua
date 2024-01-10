local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Damage = require(ServerScriptService.Server.Classes.Damage)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TagBrutal = {}
TagBrutal.__index = TagBrutal

export type TagBrutal = typeof(setmetatable({} :: {}, TagBrutal))

function TagBrutal.new(goon): TagBrutal
	local self: TagBrutal = setmetatable({}, TagBrutal)

	local trove = Trove.new()
	trove:Connect(goon.WillDealDamage, function(damage: Damage.Damage)
		damage.Amount *= 2
		trove:Clean()
	end)

	return self
end

function TagBrutal.Destroy(self: TagBrutal) end

return TagBrutal
