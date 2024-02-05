local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuickCurrency = require(ReplicatedStorage.Shared.Util.QuickCurrency)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Battlers = {
	OpeningCutsceneOrcishGeneral = {
		ModelName = "OrcGeneral",
		Name = "Orcish General",
		BattlegroundName = "World0",
		BaseId = "Camp",
		Rewards = {},
		WeaponId = "OrcishGrimoire",
		Deck = {
			OrcWarrior = 3,
			OrcChampion = 5,
			Draugr = 5,
			Berserker = 5,
			Dragon = 5,
			RainOfArrows = 5,
			CheatMoreSupplies = 1,
			Dragon = 5,
		},
		Brain = {
			Id = "NaiveOrder",
			Order = {
				{ CardId = "OrcWarrior", Count = 3 },
				{ CardId = "CheatMoreSupplies", Count = 1 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "RainOfArrows", Count = 1 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Draugr", Count = 1 },
				{ CardId = "Berserker", Count = 3 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "OrcChampion", Count = 100 },
			},
		},
	},
	-- world 1
	Peasant = {
		Name = "Peasant",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(10, 20, 50) } },
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(5, 10, 20) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "Gems", Amount = 1 } },
			{ Chance = 0.01, Result = { Type = "Card", CardId = "Heal" } },
		},
		WeaponId = "WoodenBow",
		Deck = {
			Peasant = 1,
			Militia = 1,
			Heal = 1,
		},
		Brain = {
			Id = "NaiveOrder",
			Order = {
				{ CardId = "Peasant", Count = 3 },
				{ CardId = "Heal", Count = 1 },
				{ CardId = "Peasant", Count = 1 },
				{ CardId = "Militia", Count = 1 },
			},
		},
	},
	Noble = {
		Name = "Noble",
		BattlegroundName = "World1",
		BaseId = "ClassicReborn",
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(25, 50, 100) } },
		},
		WeaponId = "SimpleWand",
		Deck = {
			Peasant = 2,
			Recruit = 1,
			Hunter = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	Knight = {
		Name = "Knight",
		BattlegroundName = "World1",
		BaseId = "ClassicReborn",
		Reward = 50,
		WeaponId = "Crossbow",
		Deck = {
			Footman = 1,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	King = {
		Name = "King",
		BattlegroundName = "World1",
		BaseId = "Peaks",
		Reward = 100,
		WeaponId = "ArcaneRod",
		Deck = {
			Footman = 1,
			Hunter = 1,
			Peasant = 2,
			Recruitment = 3,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	MinerBoss = {
		Name = "Miner Boss",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Reward = 300,
		WeaponId = "Crossbow",
		Deck = {
			Miner = 1,
			Demolitionist = 1,
			PickaxeThrower = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},

	RebelLeader = {
		Name = "Rebel Leader",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Reward = 500,
		WeaponId = "Crossbow",
		Deck = {
			Peasant = 1,
			Recruit = 1,
			Hunter = 1,
			Recruitment = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},

	CultLeader = {
		Name = "Cult Leader",
		BattlegroundName = "World1",
		BaseId = "Grim",
		Reward = 500,
		WeaponId = "OrcishGrimoire",
		Deck = {
			Cultist = 1,
			UndeadWarrior = 1,
			Heal = 1,
		},
		Brain = {
			Id = "NaiveOrder",
			Order = {
				{ CardId = "UndeadWarrior", Count = 3 },
				{ CardId = "Heal", Count = 1 },
				{ CardId = "Cultist", Count = 3 },
			},
		},
	},
	VikingSailor = {
		Name = "Viking Sailor",
		BattlegroundName = "World1",
		BaseId = "VikingPalisade",
		Reward = 600,
		WeaponId = "CrudeThrownAxe",
		Deck = {
			Berserker = 1,
			VikingWarrior = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},

	-- world 2
	VikingRunt = {
		Name = "Viking Runt",
		BattlegroundName = "World2",
		BaseId = "Camp",
		Reward = 150,
		WeaponId = "WoodenBow",
		Deck = {
			Berserker = 1,
			Recruit = 1,
			VikingWarrior = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	VikingWarrior = {
		Name = "Viking Warrior",
		BattlegroundName = "World2",
		BaseId = "VikingPalisade",
		Reward = 250,
		WeaponId = "CrudeThrownAxe",
		Deck = {
			Berserker = 1,
			Recruit = 1,
			VikingWarrior = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	VikingChief = {
		Name = "Viking Chief",
		BattlegroundName = "World2",
		BaseId = "VikingPalisade",
		Reward = 375,
		WeaponId = "CrudeThrownAxe",
		Deck = {
			Recruit = 1,
			VikingWarrior = 1,
			Hunter = 1,
			Berserker = 1,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	VikingKing = {
		Name = "Viking King",
		BattlegroundName = "World2",
		BaseId = "VikingPalisade",
		Reward = 500,
		WeaponId = "CrudeThrownAxe",
		Deck = {
			Recruit = 1,
			Footman = 1,
			VikingWarrior = 1,
			Hunter = 1,
			Berserker = 1,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},

	-- world 3
	ElfCommoner = {
		Name = "Elf Commoner",
		BattlegroundName = "World3",
		BaseId = "Camp",
		Reward = 750,
		WeaponId = "ElvenBow",
		Deck = {
			ElfBrawler = 1,
			ElfRanger = 1,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	ElfHunter = {
		Name = "Elf Hunter",
		BattlegroundName = "World3",
		BaseId = "ElvenKeep",
		Reward = 1000,
		WeaponId = "ElvenBow",
		Deck = {
			ElfBrawler = 1,
			ElfRanger = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	ElfWarrior = {
		Name = "Elf Warrior",
		BattlegroundName = "World3",
		BaseId = "ElvenKeep",
		Reward = 1300,
		WeaponId = "ThrowingKnife",
		Deck = {
			ElfBrawler = 1,
			ElfRanger = 1,
			Heal = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	ElfKing = {
		Name = "Elf King",
		BattlegroundName = "World3",
		BaseId = "ElvenKeep",
		Reward = 1750,
		WeaponId = "ElvenBow",
		Deck = {
			ElfBrawler = 1,
			ElfRanger = 1,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},

	BanditLeader = {
		Name = "Bandit Leader",
		BattlegroundName = "World3",
		BaseId = "ElvenKeep",
		Reward = 3000,
		WeaponId = "FairyBow",
		Deck = {
			BanditRogue = 1,
			BanditDuelist = 1,
			BanditScout = 1,
			BanditOfficer = 1,
			Mob = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},

	-- world 4
	OrcGrunt = {
		Name = "Orc Grunt",
		BattlegroundName = "World4",
		BaseId = "Camp",
		Reward = 2000,
		WeaponId = "CrudeThrownAxe",
		Deck = {
			OrcWarrior = 1,
			OrcChampion = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	OrcBrute = {
		Name = "Orc Brute",
		BattlegroundName = "World4",
		BaseId = "VikingPalisade",
		Reward = 2500,
		WeaponId = "SpellBook",
		Deck = {
			OrcWarrior = 1,
			OrcChampion = 1,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	OrcFighter = {
		Name = "Orc Fighter",
		BattlegroundName = "World4",
		BaseId = "VikingPalisade",
		Reward = 3250,
		WeaponId = "Javelin",
		Deck = {
			OrcWarrior = 1,
			OrcChampion = 1,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	OrcGeneral = {
		Name = "Orc General",
		BattlegroundName = "World4",
		BaseId = "Sandstone",
		Reward = 4500,
		WeaponId = "Javelin",
		Deck = {
			OrcWarrior = 1,
			OrcChampion = 1,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
}

return Sift.Dictionary.map(Battlers, function(battler, id)
	local modelName = battler.ModelName or id
	local model = ReplicatedStorage.Assets.Models.Battlers:FindFirstChild(modelName)
	assert(model, `Battler {id} missing model`)

	return Sift.Dictionary.merge(battler, {
		Id = id,
		Model = model,
	})
end)
