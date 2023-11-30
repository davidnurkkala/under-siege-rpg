local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Battlers = {
	Noob = {
		Name = "Noob",
		Reward = 1,
		WeaponId = "WoodenBow",
		Power = 100,
		Deck = {
			Peasant = 1,
			Recruit = 1,
		},
	},

	VikingWarrior = {
		Name = "Viking Warrior",
		Reward = 3,
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
		Reward = 5,
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
		Reward = 10,
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
		Reward = 25,
		WeaponId = "WoodenBow",
		Power = 200000,
		Deck = {
			Recruit = 32,
			Footman = 4,
			VikingWarrior = 16,
			Hunter = 32,
			Berserker = 16,
		},
	},

	ElfHunter = {
		Name = "Elf Hunter",
		Reward = 50,
		WeaponId = "WoodenBow",
		Power = 300000,
		Deck = {
			Recruit = 32,
			Footman = 4,
			VikingWarrior = 16,
			Hunter = 32,
			Berserker = 16,
		},
	},

	ElfWarrior = {
		Name = "Elf Warrior",
		Reward = 100,
		WeaponId = "WoodenBow",
		Power = 400000,
		Deck = {
			Recruit = 32,
			Footman = 4,
			VikingWarrior = 16,
			Hunter = 32,
			Berserker = 16,
		},
	},

	ElfKing = {
		Name = "Elf King",
		Reward = 250,
		WeaponId = "WoodenBow",
		Power = 500000,
		Deck = {
			Recruit = 32,
			Footman = 4,
			VikingWarrior = 16,
			Hunter = 32,
			Berserker = 16,
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
