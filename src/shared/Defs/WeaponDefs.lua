local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Weapons = {
	-- world 1
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
		Power = 10.5,
		Price = 300,
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
		Power = 35.9,
		Price = 6600,
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
		Power = 85.3,
		Price = 38900,
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

	-- world 2
	RecurveBow = {
		Name = "Recurve Bow",
		Power = 166.6,
		Price = 141200,
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
	BluesteelCrossbow = {
		Name = "Bluesteel Crossbow",
		Power = 287.9,
		Price = 391100,
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
		Power = 457.3,
		Price = 909400,
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
		Power = 682.6,
		Price = 1869700,
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

	-- world 3
	ElvenBow = {
		Name = "Elven Bow",
		Power = 972,
		Price = 3508000,
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
	FairyBow = {
		Name = "Fairy Bow",
		Power = 1333.3,
		Price = 6132300,
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
	WillowCrossbow = {
		Name = "Willow Crossbow",
		Power = 1774.6,
		Price = 10132200,
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
	ArcaneRod = {
		Name = "Arcane Rod",
		Power = 2304,
		Price = 15988500,
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

	-- world 4
	ThrowingKnife = {
		Name = "Throwing Knife",
		Power = 2929.3,
		Price = 24282800,
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
	Javelin = {
		Name = "Javelin",
		Power = 3658.6,
		Price = 35707100,
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
		Power = 4500,
		Price = 51073400,
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
		Power = 5461.3,
		Price = 71323300,
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
}

return Sift.Dictionary.map(Weapons, function(def, id)
	local model = ReplicatedStorage.Assets.Weapons:FindFirstChild(id)
	assert(model, `Missing model for weapon {id}`)

	return Sift.Dictionary.merge(def, {
		Id = id,
		Model = model,
	}), id
end)
