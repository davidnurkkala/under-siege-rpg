local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Battlers = {
	-- world 1
	Peasant = {
		Name = "Peasant",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Reward = 5,
		WeaponId = "WoodenBow",
		Power = 10,
		Deck = {
			Peasant = 1,
			Recruit = 1,
		},
	},
	Noble = {
		Name = "Noble",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Reward = 25,
		WeaponId = "SimpleWand",
		Power = 1000,
		Deck = {
			Peasant = 4,
			Recruit = 1,
			Hunter = 1,
			RainOfArrows = 1,
		},
	},
	Knight = {
		Name = "Knight",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Reward = 50,
		WeaponId = "Crossbow",
		Power = 4100,
		Deck = {
			Footman = 2,
			Heal = 2,
			RainOfArrows = 2,
		},
	},
	King = {
		Name = "King",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Reward = 100,
		WeaponId = "ArcaneRod",
		Power = 13000,
		Deck = {
			Footman = 2,
			Hunter = 8,
			Mob = 2,
			Recruitment = 8,
		},
	},
	MinerBoss = {
		Name = "Miner Boss",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Reward = 300,
		WeaponId = "Crossbow",
		Power = 50000,
		Deck = {
			Miner = 32,
			Demolitionist = 64,
			PickaxeThrower = 32,
		},
	},

	RebelLeader = {
		Name = "Rebel Leader",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Reward = 500,
		WeaponId = "Crossbow",
		Power = 75000,
		Deck = {
			Peasant = 32,
			Recruit = 64,
			Footman = 32,
			Hunter = 32,
			Mob = 24,
			Recruitment = 8,
		},
	},

	-- world 2
	VikingRunt = {
		Name = "Viking Runt",
		BattlegroundName = "World2",
		BaseName = "VikingBase",
		Reward = 150,
		WeaponId = "WoodenBow",
		Power = 33000,
		Deck = {
			Berserker = 1,
			Recruit = 1,
			VikingWarrior = 1,
		},
	},
	VikingWarrior = {
		Name = "Viking Warrior",
		BattlegroundName = "World2",
		BaseName = "VikingBase",
		Reward = 250,
		WeaponId = "CrudeThrownAxe",
		Power = 75000,
		Deck = {
			Berserker = 1,
			Recruit = 4,
			VikingWarrior = 4,
			RainOfArrows = 1,
		},
	},
	VikingChief = {
		Name = "Viking Chief",
		BattlegroundName = "World2",
		BaseName = "VikingBase",
		Reward = 375,
		WeaponId = "CrudeThrownAxe",
		Power = 150000,
		Deck = {
			Recruit = 8,
			VikingWarrior = 8,
			Hunter = 16,
			Berserker = 4,
			Heal = 1,
			RainOfArrows = 4,
		},
	},
	VikingKing = {
		Name = "Viking King",
		BattlegroundName = "World2",
		BaseName = "VikingBase",
		Reward = 500,
		WeaponId = "CrudeThrownAxe",
		Power = 300000,
		Deck = {
			Recruit = 32,
			Footman = 4,
			VikingWarrior = 16,
			Hunter = 32,
			Berserker = 16,
			Heal = 4,
			RainOfArrows = 8,
		},
	},

	-- world 3
	ElfCommoner = {
		Name = "Elf Commoner",
		BattlegroundName = "World3",
		BaseName = "ElfBase",
		Reward = 750,
		WeaponId = "ElvenBow",
		Power = 520000,
		Deck = {
			ElfBrawler = 12,
			ElfRanger = 8,
			Heal = 16,
			RainOfArrows = 8,
		},
	},
	ElfHunter = {
		Name = "Elf Hunter",
		BattlegroundName = "World3",
		BaseName = "ElfBase",
		Reward = 1000,
		WeaponId = "ElvenBow",
		Power = 880000,
		Deck = {
			ElfBrawler = 16,
			ElfRanger = 12,
			RainOfArrows = 32,
		},
	},
	ElfWarrior = {
		Name = "Elf Warrior",
		BattlegroundName = "World3",
		BaseName = "ElfBase",
		Reward = 1300,
		WeaponId = "ThrowingKnife",
		Power = 1400000,
		Deck = {
			ElfBrawler = 18,
			ElfRanger = 16,
			Heal = 32,
		},
	},
	ElfKing = {
		Name = "Elf King",
		BattlegroundName = "World3",
		BaseName = "ElfBase",
		Reward = 1750,
		WeaponId = "ElvenBow",
		Power = 2200000,
		Deck = {
			ElfBrawler = 32,
			ElfRanger = 18,
			Heal = 16,
			RainOfArrows = 16,
		},
	},

	-- world 4
	OrcGrunt = {
		Name = "Orc Grunt",
		BattlegroundName = "World4",
		BaseName = "VikingBase",
		Reward = 2000,
		WeaponId = "CrudeThrownAxe",
		Power = 3300000,
		Deck = {
			OrcWarrior = 32,
			OrcChampion = 16,
			RainOfArrows = 64,
		},
	},
	OrcBrute = {
		Name = "Orc Brute",
		BattlegroundName = "World4",
		BaseName = "VikingBase",
		Reward = 2500,
		WeaponId = "SpellBook",
		Power = 4700000,
		Deck = {
			OrcWarrior = 32,
			OrcChampion = 16,
			Heal = 32,
			RainOfArrows = 64,
		},
	},
	OrcFighter = {
		Name = "Orc Fighter",
		BattlegroundName = "World4",
		BaseName = "VikingBase",
		Reward = 3250,
		WeaponId = "Javelin",
		Power = 6700000,
		Deck = {
			OrcWarrior = 32,
			OrcChampion = 32,
			Heal = 32,
			RainOfArrows = 64,
		},
	},
	OrcGeneral = {
		Name = "Orc General",
		BattlegroundName = "World4",
		BaseName = "VikingBase",
		Reward = 4500,
		WeaponId = "Javelin",
		Power = 9250000,
		Deck = {
			OrcWarrior = 64,
			OrcChampion = 32,
			Heal = 64,
			RainOfArrows = 128,
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
