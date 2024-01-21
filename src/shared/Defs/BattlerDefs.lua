local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Battlers = {
	-- world 1
	Peasant = {
		Name = "Peasant",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Rewards = {
			{ Type = "Currency", CurrencyType = "Coins", Amount = 10 },
			{ Type = "Currency", CurrencyType = "Gems", Amount = 1 },
			{ Type = "Card", CardId = "Peasant" },
		},
		WeaponId = "WoodenBow",
		Deck = {
			Peasant = 1,
			Heal = 1,
		},
		Brain = {
			Id = "NaiveOrder",
			Order = {
				{ CardId = "Peasant", Count = 3 },
				{ CardId = "Heal", Count = 1 },
			},
		},
	},
	Noble = {
		Name = "Noble",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Reward = 25,
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
		BaseName = "Tower",
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
		BaseName = "Tower",
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
		BaseName = "Tower",
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
		BaseName = "Tower",
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

	-- world 2
	VikingRunt = {
		Name = "Viking Runt",
		BattlegroundName = "World2",
		BaseName = "VikingBase",
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
		BaseName = "VikingBase",
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
		BaseName = "VikingBase",
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
		BaseName = "VikingBase",
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
		BaseName = "ElfBase",
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
		BaseName = "ElfBase",
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
		BaseName = "ElfBase",
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
		BaseName = "ElfBase",
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
		BattlegroundName = "World1",
		BaseName = "ElfBase",
		Reward = 3000,
		WeaponId = "Crossbow",
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
		BaseName = "VikingBase",
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
		BaseName = "VikingBase",
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
		BaseName = "VikingBase",
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
		BaseName = "VikingBase",
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
	local model = ReplicatedStorage.Assets.Models.Battlers:FindFirstChild(id)
	assert(model, `Battler {id} missing model`)

	return Sift.Dictionary.merge(battler, {
		Id = id,
		Model = model,
	})
end)
