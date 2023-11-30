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
			return 1 + 0.4 * level
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
			return 2 + 0.75 * level
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
			return 2 + level
		end,
		HealthMax = function(level)
			return 10 + 2 * (level - 1)
		end,
	},

	Hunter = {
		Name = "Hunter",
		ModelName = "Hunter",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
		},
		Animations = {
			Idle = "HunterIdle",
			Walk = "HunterWalk",
			Attack = "HunterAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
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
			return 0.35
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 2.5 + level * 0.75
		end,
		HealthMax = function(level)
			return 9 + 1.5 * (level - 1)
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
			return 1 + 0.75 * level
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
			return 1 + level
		end,
		HealthMax = function(level)
			return 12 + 1 * (level - 1)
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
