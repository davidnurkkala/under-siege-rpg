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

	World2Pets = {
		Name = "World 2 Pets",
		EggId = "World1",
		Price = {
			Secondary = 100,
		},
		WeightTable = {
			{ Result = "Bully", Weight = 4 },
			{ Result = "Liony", Weight = 3 },
			{ Result = "Rhiny", Weight = 2 },
			{ Result = "Wolfy", Weight = 1 },
		},
	},

	World3Pets = {
		Name = "World 3 Pets",
		EggId = "World1",
		Price = {
			Secondary = 200,
		},
		WeightTable = {
			{ Result = "Goaty", Weight = 4 },
			{ Result = "Mousey", Weight = 3 },
			{ Result = "Batsy", Weight = 2 },
			{ Result = "Foxy", Weight = 1 },
		},
	},

	World4Pets = {
		Name = "World 4 Pets",
		EggId = "World1",
		Price = {
			Secondary = 300,
		},
		WeightTable = {
			{ Result = "MooCow", Weight = 4 },
			{ Result = "Tigre", Weight = 3 },
			{ Result = "Monke", Weight = 2 },
			{ Result = "Slimey", Weight = 1 },
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
