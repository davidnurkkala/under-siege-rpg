local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local function scaling(base, perLevel, level)
	return base + perLevel * (level - 1)
end

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
			return scaling(1, 0.25, level)
		end,
		HealthMax = function(level)
			return scaling(10, 1, level)
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
			return scaling(2, 0.25, level)
		end,
		HealthMax = function(level)
			return scaling(15, 1, level)
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
			return scaling(2.5, 0.5, level)
		end,
		HealthMax = function(level)
			return scaling(25, 2.5, level)
		end,
	},

	Hunter = {
		Name = "Hunter",
		ModelName = "Hunter",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "Arrow1",
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
			return scaling(0.5, 0.1, level)
		end,
		HealthMax = function(level)
			return scaling(5, 1, level)
		end,
	},

	Mage = {
		Name = "Mage",
		ModelName = "Mage",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "MagicStar1",
		},
		Animations = {
			Walk = "MageWalk",
			Attack = "MageAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Shoot = { "WandCast1", "WandCast2", "WandCast3" },
			Hit = { "MagicImpact1", "MagicImpact2", "MagicImpact3" },
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
			return scaling(0.5, 0.1, level)
		end,
		HealthMax = function(level)
			return scaling(5, 1, level)
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
			return 0.075
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return scaling(2.5, 0.5, level)
		end,
		HealthMax = function(level)
			return scaling(25, 2.5, level)
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
			return 0.1
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return scaling(5, 0.5, level)
		end,
		HealthMax = function(level)
			return scaling(5, 1, level)
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
