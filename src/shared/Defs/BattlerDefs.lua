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
		WeaponId = "WoodenBow",
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
		WeaponId = "WoodenBow",
		Power = 10000,
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
		WeaponId = "WoodenBow",
		Power = 100000,
		Deck = {
			Recruit = 8,
			Footman = 2,
			Hunter = 8,
			Heal = 2,
			Mob = 1,
		},
	},

	-- world 2
	VikingRunt = {
		Name = "Viking Runt",
		BattlegroundName = "World2",
		BaseName = "VikingBase",
		Reward = 150,
		WeaponId = "WoodenBow",
		Power = 200000,
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
		WeaponId = "WoodenBow",
		Power = 300000,
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
		WeaponId = "WoodenBow",
		Power = 450000,
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
		WeaponId = "WoodenBow",
		Power = 750000,
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
		BattlegroundName = "World2",
		BaseName = "Tower",
		Reward = 750,
		WeaponId = "ElvenBow",
		Power = 1000000,
		Deck = {
			ElfBrawler = 12,
			ElfRanger = 8,
			Heal = 16,
			RainOfArrows = 8,
		},
	},
	ElfHunter = {
		Name = "Elf Hunter",
		BattlegroundName = "World2",
		BaseName = "Tower",
		Reward = 1000,
		WeaponId = "ElvenBow",
		Power = 2000000,
		Deck = {
			ElfBrawler = 16,
			ElfRanger = 12,
			RainOfArrows = 32,
		},
	},
	ElfWarrior = {
		Name = "Elf Warrior",
		BattlegroundName = "World2",
		BaseName = "Tower",
		Reward = 1300,
		WeaponId = "ElvenBow",
		Power = 4000000,
		Deck = {
			ElfBrawler = 18,
			ElfRanger = 16,
			Heal = 32,
		},
	},
	ElfKing = {
		Name = "Elf King",
		BattlegroundName = "World2",
		BaseName = "Tower",
		Reward = 1750,
		WeaponId = "ElvenBow",
		Power = 10000000,
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
		BattlegroundName = "World3",
		BaseName = "VikingBase",
		Reward = 2000,
		WeaponId = "WoodenBow",
		Power = 25000000,
		Deck = {
			OrcWarrior = 32,
			OrcChampion = 16,
			RainOfArrows = 64,
		},
	},
	OrcBrute = {
		Name = "Orc Brute",
		BattlegroundName = "World3",
		BaseName = "VikingBase",
		Reward = 2500,
		WeaponId = "WoodenBow",
		Power = 50000000,
		Deck = {
			OrcWarrior = 32,
			OrcChampion = 16,
			Heal = 32,
			RainOfArrows = 64,
		},
	},
	OrcFighter = {
		Name = "Orc Fighter",
		BattlegroundName = "World3",
		BaseName = "VikingBase",
		Reward = 3250,
		WeaponId = "Javelin",
		Power = 75000000,
		Deck = {
			OrcWarrior = 32,
			OrcChampion = 32,
			Heal = 32,
			RainOfArrows = 64,
		},
	},
	OrcGeneral = {
		Name = "Orc General",
		BattlegroundName = "World3",
		BaseName = "VikingBase",
		Reward = 4500,
		WeaponId = "Javelin",
		Power = 100000000,
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
