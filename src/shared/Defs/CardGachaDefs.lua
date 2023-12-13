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
	-----------
	-- GOONS --
	-----------
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
	World2Goons = {
		Name = "World 2 Soldiers",
		Price = {
			Secondary = 50,
		},
		WeightTable = {
			{ Result = "Footman", Weight = 4 },
			{ Result = "Mage", Weight = 4 },
			{ Result = "VikingWarrior", Weight = 2 },
			{ Result = "Berserker", Weight = 1 },
		},
	},
	World3Goons = {
		Name = "World 3 Soldiers",
		Price = {
			Secondary = 100,
		},
		WeightTable = {
			{ Result = "Footman", Weight = 3 },
			{ Result = "ElfBrawler", Weight = 2 },
			{ Result = "ElfRanger", Weight = 1 },
		},
	},

	---------------
	-- ABILITIES --
	---------------
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
	World2Abilities = {
		Name = "World 2 Abilities",
		Price = {
			Secondary = 10,
		},
		WeightTable = {
			{ Result = "Heal", Weight = 4 },
			{ Result = "RainOfArrows", Weight = 3 },
		},
	},
	World3Abilities = {
		Name = "World 3 Abilities",
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
