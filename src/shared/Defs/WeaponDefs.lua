local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)
local WeaponTypeDefs = require(ReplicatedStorage.Shared.Defs.WeaponTypeDefs)

local Weapons = {
	WoodenBow = {
		Name = "Wooden Bow",
		WeaponType = "Bow",
		Description = "A simple wooden bow.",
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
		WeaponType = "Bow",
		Description = "A somewhat honed bow favored by hunters for its light weight and accuracy.",
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
		WeaponType = "Crossbow",
		Description = "A simple crossbow with basic mechanisms.",
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
		WeaponType = "Magic",
		Description = "One of the simplest implements one can use to cast magic.",
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
		WeaponType = "Bow",
		Description = "A somewhat rare, compact bow with a peculiar shape. Powerful despite its smaller size.",
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
		WeaponType = "Crossbow",
		Description = "A crossbow incorporating the Vikings' infamous bluesteel. It is a ferocious weapon.",
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
		WeaponType = "Bow",
		Description = "A bow laden with metal reinforcements. It takes tremendous strength to draw, and only trained soldiers dare try.",
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
		WeaponType = "Magic",
		Description = "A staff suffused with the natural magic of the elves. A powerful magical tool.",
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
	ElvenBow = {
		Name = "Elven Bow",
		WeaponType = "Bow",
		Description = "An unbelievably perfect wooden bow. Some say the elves grow wood into the exact shape using magic, never putting knife to bark, but the truth is a closely guarded secret.",
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
		WeaponType = "Bow",
		Description = "An elven bow that has been enhanced with fairy magic. Mysterious creatures, fairies seem to have no rhyme or reason for their behavior, and this bow is just one of many examples of their mischief.",
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
		WeaponType = "Crossbow",
		Description = "A simple crossbow crafted carefully from a limb of willow. It is finely crafted and meticulously balanced.",
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
		WeaponType = "Magic",
		Description = "An immaculate enchanted rod brimming with arcane power.",
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
		WeaponType = "Thrown",
		Description = "A devious weapon that's tricky to use well. Favored by ne'er-do-wells that prefer to keep their weapons hidden from view.",
		HoldPartName = "RightHand",
		ProjectileName = "ThrowingKnife",
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
		WeaponType = "Thrown",
		Description = "Javelins are among the oldest ranged weapons in history, and the simplicity and power of these thrown spears is not to be underestimated.",
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
		WeaponType = "Thrown",
		Description = "A cruel stone axe of orcish design. They're mass-produced by orcish peons and deployed en masse by their fearsome horde.",
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
	OrcishGrimoire = {
		Name = "Orcish Grimoire",
		WeaponType = "Magic",
		Description = "The grimoire of an orcish warlock, filled with scratched runes that emanate malice.",
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

	assert(WeaponTypeDefs[def.WeaponType], `Bad or missing weapon type for weapon {id}`)

	return Sift.Dictionary.merge(def, {
		Id = id,
		Model = model,
	}), id
end)
