local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Weapons = {
	WoodenBow = {
		Name = "Wooden Bow",
		Power = 1,
		Price = 0,
		AttackCooldownTime = 0.4,
		HoldPartName = "LeftHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	HuntersBow = {
		Name = "Hunter's Bow",
		Power = 10,
		Price = 100,
		AttackCooldownTime = 0.4,
		HoldPartName = "LeftHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	Crossbow = {
		Name = "Crossbow",
		Power = 50,
		Price = 7500,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "CrossbowIdle",
			Shoot = "CrossbowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	SimpleWand = {
		Name = "Apprentice Wand",
		Power = 250,
		Price = 75000,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "MagicStar1",
		Animations = {
			Idle = "WandIdle",
			Shoot = "WandShoot",
		},
		Sounds = {
			Shoot = { "WandCast1", "WandCast2", "WandCast3" },
			Hit = { "MagicImpact1", "MagicImpact2", "MagicImpact3" },
		},
	},
	RecurveBow = {
		Name = "Recurve Bow",
		Power = 1000,
		Price = 1.5e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "LeftHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	ElvenBow = {
		Name = "Elven Bow",
		Power = 2000,
		Price = 3e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "LeftHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	RoughwoodStaff = {
		Name = "Roughwood Staff",
		Power = 3500,
		Price = 6e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "MagicStar1",
		Animations = {
			Idle = "WandIdle",
			Shoot = "WandShoot",
		},
		Sounds = {
			Shoot = { "WandCast1", "WandCast2", "WandCast3" },
			Hit = { "MagicImpact1", "MagicImpact2", "MagicImpact3" },
		},
	},
	FairyBow = {
		Name = "Fairy Bow",
		Power = 5000,
		Price = 8e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "LeftHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	Javelin = {
		Name = "Javelin",
		Power = 5000,
		Price = 10e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "Javelin1",
		Animations = {
			Idle = "JavelinIdle",
			Shoot = "JavelinThrow",
		},
		Sounds = {
			Shoot = { "WhooshMedium1", "WhooshMedium2", "WhooshMedium3", "WhooshMedium4", "WhooshMedium5", "WhooshMedium6" },
			Hit = { "MediumProjectileImpact1", "MediumProjectileImpact2", "MediumProjectileImpact3", "MediumProjectileImpact4" },
		},
	},
	CrudeThrownAxe = {
		Name = "Crude Throwing Axe",
		Power = 7500,
		Price = 30e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "ThrownAxeCrude",
		Animations = {
			Idle = "JavelinIdle",
			Shoot = "JavelinThrow",
		},
		Sounds = {
			Shoot = { "WhooshMedium1", "WhooshMedium2", "WhooshMedium3", "WhooshMedium4", "WhooshMedium5", "WhooshMedium6" },
			Hit = { "MediumProjectileImpact1", "MediumProjectileImpact2", "MediumProjectileImpact3", "MediumProjectileImpact4" },
		},
	},
	SpellBook = {
		Name = "Spell Book",
		Power = 9000,
		Price = 35e6,
		AttackCooldownTime = 0.6,
		HoldPartName = "RightHand",
		ProjectileName = "MagicStar2",
		Animations = {
			Idle = "BookIdle",
			Shoot = "BookShoot",
		},
		Sounds = {
			Shoot = { "WandCast1", "WandCast2", "WandCast3" },
			Hit = { "MagicImpact1", "MagicImpact2", "MagicImpact3" },
		},
	},
	ArcaneRod = {
		Name = "Arcane Rod",
		Power = 11000,
		Price = 39e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "MagicStar2",
		Animations = {
			Idle = "WandIdle",
			Shoot = "WandShoot",
		},
		Sounds = {
			Shoot = { "WandCast1", "WandCast2", "WandCast3" },
			Hit = { "MagicImpact1", "MagicImpact2", "MagicImpact3" },
		},
	},
	ThrowingKnife = {
		Name = "Throwing Knife",
		Power = 13000,
		Price = 44e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "ThrownAxeCrude",
		Animations = {
			Idle = "JavelinIdle",
			Shoot = "JavelinThrow",
		},
		Sounds = {
			Shoot = { "WhooshMedium1", "WhooshMedium2", "WhooshMedium3", "WhooshMedium4", "WhooshMedium5", "WhooshMedium6" },
			Hit = { "MediumProjectileImpact1", "MediumProjectileImpact2", "MediumProjectileImpact3", "MediumProjectileImpact4" },
		},
	},
	WillowCrossbow = {
		Name = "Willow Crossbow",
		Power = 15000,
		Price = 48e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "CrossbowIdle",
			Shoot = "CrossbowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	BluesteelCrossbow = {
		Name = "Bluesteel Crossbow",
		Power = 17000,
		Price = 54e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "CrossbowIdle",
			Shoot = "CrossbowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	ReinforcedBow = {
		Name = "Reinforced Bow",
		Power = 20000,
		Price = 59e6,
		AttackCooldownTime = 0.4,
		HoldPartName = "LeftHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
}

return Sift.Dictionary.map(Weapons, function(def, id)
	local model = ReplicatedStorage.Assets.Weapons:FindFirstChild(id)
	assert(model, `Missing model for weapon {id}`)

	return Sift.Dictionary.merge(def, {
		Id = id,
		Model = model,
	}), id
end)
