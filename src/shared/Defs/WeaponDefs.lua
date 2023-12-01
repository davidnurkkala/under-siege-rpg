local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Weapons = {
	WoodenBow = {
		Name = "Wooden Bow",
		Power = 1,
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
		Name = "Hunters Bow",
		Power = 5,
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
		Power = 10,
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
		Power = 50,
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
		Power = 200,
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
		Power = 250,
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

	ElvenBow = {
		Name = "Elven Bow",
		Power = 250,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
		ProjectileName = "Arrow1",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
		Sounds = {
			Shoot = { "WhooshMedium1", "WhooshMedium2", "WhooshMedium3", "WhooshMedium4", "WhooshMedium5", "WhooshMedium6" },
			Hit = { "MediumProjectileImpact1", "MediumProjectileImpact2", "MediumProjectileImpact3", "MediumProjectileImpact4" },
		},
	},
}

return Sift.Dictionary.map(Weapons, function(def, id)
	local model = ReplicatedStorage.Assets.Weapons:FindFirstChild(id)
	assert(model, `Missing model for weapon {id}`)

	if not def.Requirements then def = Sift.Dictionary.merge(def, {
		Requirements = {
			Currency = {
				Primary = def.Power * 25,
			},
		},
	}) end

	return Sift.Dictionary.merge(def, {
		Id = id,
		Model = model,
	}), id
end)
