local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CurrencyHelper = require(ReplicatedStorage.Shared.Util.CurrencyHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WeightTable = require(ReplicatedStorage.Shared.Classes.WeightTable)

export type Gacha = {
	Name: string,
	Id: string,
	Price: CurrencyHelper.Price,
	WeightTable: WeightTable.WeightTable,
}

local Gachas = {
	World1Goons = {
		Name = "World 1 Soldiers",
		Price = {
			Secondary = 5,
		},
		WeightTable = {
			{ Result = "Peasant", Weight = 6 },
			{ Result = "Recruit", Weight = 2 },
			{ Result = "Hunter", Weight = 2 },
			{ Result = "Mage", Weight = 1 },
		},
	},
	World1Abilities = {
		Name = "World 1 Abilities",
		Price = {
			Secondary = 10,
		},
		WeightTable = {
			{ Result = "Heal", Weight = 4 },
			{ Result = "RainOfArrows", Weight = 3 },
		},
	},
}

return Sift.Dictionary.map(Gachas, function(gacha, id)
	for _, entry in gacha.WeightTable do
		assert(CardDefs[entry.Result], `Gacha {id} has result {entry.Result} which has no card def`)
	end

	return Sift.Dictionary.merge(gacha, {
		Id = id,
		WeightTable = WeightTable.new(gacha.WeightTable),
	})
end) :: { [string]: Gacha }
