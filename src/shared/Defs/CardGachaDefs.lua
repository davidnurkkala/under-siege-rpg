local ServerScriptService = game:GetService("ServerScriptService")

local WeightTable = require(ServerScriptService.Server.Classes.WeightTable)

local Gachas: { [string]: WeightTable.WeightTable } = {
	World1 = WeightTable.new({
		{ Result = "Peasant", Weight = 3 },
		{ Result = "Soldier", Weight = 1 },
		{ Result = "Hunter", Weight = 1 },
	}),
}

for gachaId, gacha in Gachas do
	print(gachaId)
	gacha:Print()
end

return Gachas
