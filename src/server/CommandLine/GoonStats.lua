local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)

local lines = {}
for _, def in CardDefs do
	if def.Type ~= "Goon" then continue end

	local goonDef = GoonDefs[def.GoonId]
	print(goonDef.Id)
	table.insert(lines, `{goonDef.Id},{goonDef.Stats.Damage(1)},{goonDef.Stats.AttackRate(1)},{def.Cost}`)
end
print(table.concat(lines, "\n"))
