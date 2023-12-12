local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Battlers = {
	Noob = {
		Name = "Noob",
		BattlegroundName = "World1",
		BaseName = "Tower",
		Reward = 5,
		WeaponId = "WoodenBow",
		Power = 100,
		Deck = {
			Peasant = 1,
			Recruit = 1,
		},
	},

	VikingWarrior = {
		Name = "Viking Warrior",
		BattlegroundName = "World1",
		BaseName = "VikingBase",
		Reward = 25,
		WeaponId = "WoodenBow",
		Power = 1000,
		Deck = {
			Berserker = 1,
			Recruit = 4,
			VikingWarrior = 4,
		},
	},

	VikingChief = {
		Name = "Viking Chief",
		BattlegroundName = "World1",
		BaseName = "VikingBase",
		Reward = 50,
		WeaponId = "WoodenBow",
		Power = 10000,
		Deck = {
			Recruit = 8,
			VikingWarrior = 8,
			Hunter = 16,
			Berserker = 4,
		},
	},

	VikingKing = {
		Name = "Viking King",
		BattlegroundName = "World1",
		BaseName = "VikingBase",
		Reward = 100,
		WeaponId = "WoodenBow",
		Power = 100000,
		Deck = {
			Recruit = 32,
			Footman = 4,
			VikingWarrior = 16,
			Hunter = 32,
			Berserker = 16,
		},
	},

	ElfCommoner = {
		Name = "Elf Commoner",
		BattlegroundName = "World2",
		BaseName = "Tower",
		Reward = 125,
		WeaponId = "ElvenBow",
		Power = 1000000,
		Deck = {
			ElfBrawler = 12,
			ElfRanger = 8,
		},
	},

	ElfHunter = {
		Name = "Elf Hunter",
		BattlegroundName = "World2",
		BaseName = "Tower",
		Reward = 200,
		WeaponId = "ElvenBow",
		Power = 2000000,
		Deck = {
			ElfBrawler = 16,
			ElfRanger = 12,
		},
	},

	ElfWarrior = {
		Name = "Elf Warrior",
		BattlegroundName = "World2",
		BaseName = "Tower",
		Reward = 300,
		WeaponId = "ElvenBow",
		Power = 4000000,
		Deck = {
			ElfBrawler = 18,
			ElfRanger = 16,
		},
	},

	ElfKing = {
		Name = "Elf King",
		BattlegroundName = "World2",
		BaseName = "Tower",
		Reward = 500,
		WeaponId = "ElvenBow",
		Power = 10000000,
		Deck = {
			ElfBrawler = 32,
			ElfRanger = 18,
		},
	},

	OrcGrunt = {
		Name = "Orc Grunt",
		BattlegroundName = "World3",
		BaseName = "VikingBase",
		Reward = 550,
		WeaponId = "WoodenBow",
		Power = 25000000,
		Deck = {
			OrcWarrior = 40,
			OrcChampion = 20,
		},
	},

	OrcBrute = {
		Name = "Orc Brute",
		BattlegroundName = "World3",
		BaseName = "VikingBase",
		Reward = 1000,
		WeaponId = "WoodenBow",
		Power = 50000000,
		Deck = {
			OrcWarrior = 42,
			OrcChampion = 22,
		},
	},

	OrcFighter = {
		Name = "Orc Fighter",
		BattlegroundName = "World3",
		BaseName = "VikingBase",
		Reward = 1500,
		WeaponId = "Javelin",
		Power = 75000000,
		Deck = {
			OrcWarrior = 46,
			OrcChampion = 24,
		},
	},

	OrcGeneral = {
		Name = "Orc General",
		BattlegroundName = "World3",
		BaseName = "VikingBase",
		Reward = 3000,
		WeaponId = "Javelin",
		Power = 100000000,
		Deck = {
			OrcWarrior = 50,
			OrcChampion = 30,
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
