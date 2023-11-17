local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Goons = {
	Peasant = {
		Name = "Peasant",
		ModelName = "Peasant",
		Brain = {
			Id = "BasicMelee",
		},
		Animations = {
			Walk = "PeasantWalk",
			Attack = "PeasantAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		AttackWindupTime = function()
			return 1
		end,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 4 + level
		end,
		HealthMax = function(level)
			return 10 + 2 * (level - 1)
		end,
	},

	Recruit = {
		Name = "Recruit",
		ModelName = "Recruit",
		Brain = {
			Id = "BasicMelee",
		},
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "GenericGoon1hMelee",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		AttackWindupTime = function()
			return 0.27
		end,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 4 + level
		end,
		HealthMax = function(level)
			return 10 + 2 * (level - 1)
		end,
	},

	Footman = {
		Name = "Footman",
		ModelName = "Footman",
		Brain = {
			Id = "BasicMelee",
		},
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "GenericGoon1hMelee",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		AttackWindupTime = function()
			return 0.27
		end,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 4 + level
		end,
		HealthMax = function(level)
			return 10 + 2 * (level - 1)
		end,
	},

	Hunter = {
		Name = "Hunter",
		ModelName = "Hunter",
		Brain = {
			Id = "BasicMelee",
		},
		Animations = {
			Walk = "HunterWalk",
			Attack = "GenericGoonShoot",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		AttackWindupTime = function()
			return 0.55
		end,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 5 + level
		end,
		HealthMax = function(level)
			return 9 + 2 * (level - 1)
		end,
	},

	Mage = {
		Name = "Mage",
		ModelName = "Mage",
		Brain = {
			Id = "BasicMelee",
		},
		Animations = {
			Walk = "MageWalk",
			Attack = "MageAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		AttackWindupTime = function()
			return 0.55
		end,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 8 + level
		end,
		HealthMax = function(level)
			return 8 + 2 * (level - 1)
		end,
	},

	VikingWarrior = {
		Name = "VikingWarrior",
		ModelName = "VikingWarrior",
		Brain = {
			Id = "BasicMelee",
		},
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "AxemanAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		AttackWindupTime = function()
			return 0.55
		end,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 9 + level
		end,
		HealthMax = function(level)
			return 12 + 2 * (level - 1)
		end,
	},

	Berserker = {
		Name = "Berserker",
		ModelName = "Berserker",
		Brain = {
			Id = "BasicMelee",
		},
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "BerserkerAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		AttackWindupTime = function()
			return 0.43
		end,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 8 + level
		end,
		HealthMax = function(level)
			return 12 + 2 * (level - 1)
		end,
	},
}

return Sift.Dictionary.map(Goons, function(goon, id)
	local model = ReplicatedStorage.Assets.Models.Goons:FindFirstChild(goon.ModelName)
	assert(model, `Missing model for goon {id}`)

	return Sift.Dictionary.merge(goon, {
		Id = id,
		Model = model,
	})
end)
