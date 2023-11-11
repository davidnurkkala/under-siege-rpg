local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Weapons = {
	WoodenBow = {
		Name = "Wooden Bow",
		Power = 1,
		AttackCooldownTime = 0.4,
		HoldPartName = "LeftHand",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	SimpleBow = {
		Name = "Hunters Bow",
		Power = 5,
		AttackCooldownTime = 0.4,
		HoldPartName = "LeftHand",
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
		Animations = {
			Idle = "WandIdle",
			Shoot = "WandShoot",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "BowHit1", "BowHit2", "BowHit3", "BowHit4" },
		},
	},
	RecurveBow = {
		Name = "Recurve Bow",
		Power = 200,
		AttackCooldownTime = 0.4,
		HoldPartName = "RightHand",
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
		Animations = {
			Idle = "JavelinIdle",
			Shoot = "JavelinThrow",
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
