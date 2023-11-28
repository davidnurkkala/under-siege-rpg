local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyHelper = require(ReplicatedStorage.Shared.Util.CurrencyHelper)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WeightTable = require(ReplicatedStorage.Shared.Classes.WeightTable)

export type Gacha = {
	Name: string,
	Id: string,
	EggId: string,
	Price: CurrencyHelper.Price,
	WeightTable: WeightTable.WeightTable,
}

local Gachas = {
	World1Pets = {
		Name = "World 1 Pets",
		EggId = "World1",
		Price = {
			Secondary = 10,
		},
		WeightTable = {
			{ Result = "Doggy", Weight = 4 },
			{ Result = "Kitty", Weight = 3 },
			{ Result = "Piggy", Weight = 2 },
			{ Result = "Bunny", Weight = 1 },
		},
	},
}

return Sift.Dictionary.map(Gachas, function(gacha, id)
	for _, entry in gacha.WeightTable do
		assert(PetDefs[entry.Result], `Gacha {id} has result {entry.Result} which has no pet def`)
	end

	return Sift.Dictionary.merge(gacha, {
		Id = id,
		WeightTable = WeightTable.new(gacha.WeightTable),
	})
end) :: { [string]: Gacha }
