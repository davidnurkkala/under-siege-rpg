local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Sift = require(ReplicatedStorage.Packages.Sift)

local function scaling(base, perLevel, level)
	return base + perLevel * (level - 1)
end

local function lerped(level1, level5, level)
	local scalar = (level - 1) / 4
	return Lerp(level1, level5, scalar)
end

local Goons = {
	Peasant = {
		Name = "Peasant",
		Description = "Untrained, unprepared, and underequipped.",
		ModelName = "Peasant",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light" },
		Animations = {
			Walk = "PeasantWalk",
			Attack = "PeasantAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
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
				return lerped(1, 2, level)
			end,
			HealthMax = function(level)
				return lerped(10, 15, level)
			end,
		},
	},

	Hunter = {
		Name = "Hunter",
		Description = "A villager with a bow, now hunting a very different kind of prey.",
		ModelName = "Hunter",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "Arrow1",
		},
		Tags = { "Ranged" },
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
		Stats = {
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
				return lerped(1, 1.5, level)
			end,
			HealthMax = function(level)
				return lerped(10, 15, level)
			end,
		},
	},

	Militia = {
		Name = "Militia",
		Description = "A peasant with minimal combat training and jury-rigged protective gear.",
		ModelName = "Militia",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "GenericGoon1hMelee",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.27
			end,
			Speed = function()
				return 0.04
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(1.5, 2.25, level)
			end,
			HealthMax = function(level)
				return lerped(15, 24, level)
			end,
		},
	},

	Spearman = {
		Name = "Spearman",
		Description = "A levied soldier with a cheap spear and little training.",
		ModelName = "Spearman",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light" },
		Animations = {
			Walk = "PeasantWalk",
			Attack = "PeasantAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
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
				return lerped(1.5, 2.5, level)
			end,
			HealthMax = function(level)
				return lerped(15, 20, level)
			end,
		},
	},

	Archer = {
		Name = "Archer",
		Description = "A levied soldier with simple arrows and basic archery training.",
		ModelName = "Archer",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "Arrow1",
		},
		Tags = { "Ranged" },
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
		Stats = {
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
				return lerped(1.5, 2, level)
			end,
			HealthMax = function(level)
				return lerped(15, 20, level)
			end,
		},
	},

	Recruit = {
		Name = "Recruit",
		Description = "A levied soldier with a cheap sword and salvaged armor.",
		ModelName = "Recruit",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "GenericGoon1hMelee",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.27
			end,
			Speed = function()
				return 0.04
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(2, 2.75, level)
			end,
			HealthMax = function(level)
				return lerped(20, 31, level)
			end,
		},
	},

	Pikeman = {
		Name = "Pikeman",
		Description = "An experienced, professional soldier with a standard polearm.",
		ModelName = "Pikeman",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light" },
		Animations = {
			Walk = "PeasantWalk",
			Attack = "PeasantAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
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
				return lerped(2, 3, level)
			end,
			HealthMax = function(level)
				return lerped(20, 25, level)
			end,
		},
	},

	Crossbowman = {
		Name = "Crossbowman",
		Description = "A professional soldier with standard gear including a well-made crossbow.",
		ModelName = "Crossbowman",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "Arrow1",
		},
		Tags = { "Ranged" },
		Animations = {
			Idle = "HunterIdle",
			Walk = "HunterWalk",
			Attack = "CrossbowmanAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
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
				return lerped(2, 2.5, level)
			end,
			HealthMax = function(level)
				return lerped(20, 25, level)
			end,
		},
	},

	Footman = {
		Name = "Footman",
		Description = "A trained professional soldier with standard issue weapons and armor.",
		ModelName = "Footman",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "GenericGoon1hMelee",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.27
			end,
			Speed = function()
				return 0.04
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(2.5, 3.25, level)
			end,
			HealthMax = function(level)
				return lerped(25, 34, level)
			end,
		},
	},

	RoyalGuard = {
		Name = "Royal Guard",
		Description = "A veteran knight clad in fine platemail. Sworn to serve the crown with considerable martial expertise.",
		ModelName = "RoyalGuard",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored" },
		Animations = {
			Walk = "RoyalGuardWalk",
			Attack = "RoyalGuardAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.27
			end,
			Speed = function()
				return 0.04
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(3, 3.75, level)
			end,
			HealthMax = function(level)
				return lerped(30, 39, level)
			end,
		},
	},

	RoyalRanger = {
		Name = "Royal Ranger",
		Description = "A veteran archer with hawk-like eyes. Sworn to serve the crown with unerring accuracy.",
		ModelName = "RoyalRanger",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "Arrow1",
		},
		Tags = { "Ranged" },
		Animations = {
			Idle = "HunterIdle",
			Walk = "HunterWalk",
			Attack = "RoyalRangerAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Shoot = { "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" },
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
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
				return lerped(2.5, 3, level)
			end,
			HealthMax = function(level)
				return lerped(25, 30, level)
			end,
		},
	},

	RoyalCavalry = {
		Name = "Royal Cavalry",
		Description = "A mounted knight ready to charge into battle. Sworn to trample the enemies of the crown under thundering hooves.",
		ModelName = "RoyalCavalry",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored", "Charger", "Brutal" },
		Animations = {
			Walk = "RoyalCavalryWalk",
			Attack = "RoyalCavalryAttack",
			Die = "RoyalCavalryDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.27
			end,
			Speed = function()
				return 0.06
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(3, 4, level)
			end,
			HealthMax = function(level)
				return lerped(30, 40, level)
			end,
		},
	},

	Miner = {
		Name = "Miner",
		Description = "A local laborer smeared in coal and filth.",
		ModelName = "Miner",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "GenericGoon1hMelee",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.2
			end,
			Speed = function()
				return 0.05
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.85
			end,
			Damage = function(level)
				return scaling(3, 1, level)
			end,
			HealthMax = function(level)
				return scaling(15, 1, level)
			end,
		},
	},

	Demolitionist = {
		Name = "Demolitionist",
		Description = "An experienced miner that throws bombs. Deals damage in an area.",
		ModelName = "Demolitionist",
		Brain = {
			Id = "Demolitionist",
			KeepDistanceRatio = 0,
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "TNT",
			ProjectileSpeed = 16,
			ProjectileArcRatio = 0.5,
		},
		Tags = { "Ranged" },
		Animations = {
			Idle = "HunterIdle",
			Walk = "SwordsmanWalk",
			Attack = "DemolitionistThrow",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Shoot = { "WhooshMedium1", "WhooshMedium2", "WhooshMedium3", "WhooshMedium4" },
			Hit = { "Explosion1" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.85
			end,
			Speed = function()
				return 0.05
			end,
			Range = function()
				return 0.4
			end,
			AttackRate = function()
				return 0.5
			end,
			Damage = function(level)
				return scaling(1, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(10, 1, level)
			end,
		},
	},

	PickaxeThrower = {
		Name = "Pickaxe Thrower",
		Description = "That's now how you're supposed to use a pickaxe, but he makes it work",
		ModelName = "PickaxeThrower",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "ThrownPickaxe",
		},
		Tags = { "Ranged" },
		Animations = {
			Idle = "HunterIdle",
			Walk = "SwordsmanWalk",
			Attack = "GenericGoonThrow",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Shoot = { "WhooshMedium1", "WhooshMedium2", "WhooshMedium3", "WhooshMedium4" },
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.85
			end,
			Speed = function()
				return 0.05
			end,
			Range = function()
				return 0.18
			end,
			AttackRate = function()
				return 1.2
			end,
			Damage = function(level)
				return scaling(2, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(12, 1, level)
			end,
		},
	},

	Mage = {
		Name = "Mage",
		Description = "A student of the magical arts lacking in any real practical experience.",
		ModelName = "Mage",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -0.25),
			ProjectileName = "MagicStar1",
		},
		Tags = { "Ranged" },
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
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.55
			end,
			Speed = function()
				return 0.05
			end,
			Range = function()
				return 0.45
			end,
			AttackRate = function()
				return 0.5
			end,
			Damage = function(level)
				return scaling(2, 0.75, level)
			end,
			HealthMax = function(level)
				return scaling(5, 1, level)
			end,
		},
	},

	VikingWarrior = {
		Name = "Viking Warrior",
		Description = "A ferocious fighter from frozen fjords fielded for fierce fighting.",
		ModelName = "VikingWarrior",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Brutal" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "AxemanAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
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
				return scaling(3, 1, level)
			end,
			HealthMax = function(level)
				return scaling(15, 2, level)
			end,
		},
	},

	Berserker = {
		Name = "Berserker",
		Description = `An offense-focused fighter known for his signature battlecry: "AAAAAAAAA!!!"`,
		ModelName = "Berserker",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light", "Charger", "Brutal" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "BerserkerAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
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
				return lerped(2, 3, level)
			end,
			HealthMax = function(level)
				return lerped(20, 25, level)
			end,
		},
	},

	Bandit = {
		Name = "Bandit",
		Description = `A dastardly ruffian armed with cheap, stolen equipment.`,
		ModelName = "Bandit",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Charger", "Light" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "GenericGoon1hMelee",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.2
			end,
			Speed = function()
				return 0.06
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(1.5, 2.5, level)
			end,
			HealthMax = function(level)
				return lerped(15, 20, level)
			end,
		},
	},

	BanditScout = {
		Name = "Bandit Scout",
		Description = "An exiled elven criminal making nefarious use of his natural talent for archery.",
		ModelName = "BanditScout",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "Arrow1",
		},
		Tags = { "Ranged" },
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
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.55
			end,
			Speed = function()
				return 0.06
			end,
			Range = function()
				return 0.3
			end,
			AttackRate = function()
				return 0.9
			end,
			Damage = function(level)
				return lerped(1.5, 2, level)
			end,
			HealthMax = function(level)
				return lerped(15, 20, level)
			end,
		},
	},

	BanditRogue = {
		Name = "Bandit Rogue",
		Description = "A cowardly fighter that attacks enemies when they are unprepared.",
		ModelName = "BanditRogue",
		Brain = {
			Id = "HitAndRunMelee",
		},
		Tags = { "Light" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "RogueAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.2
			end,
			Speed = function()
				return 0.1
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.375
			end,
			Damage = function(level)
				return lerped(3, 5, level)
			end,
			HealthMax = function(level)
				return lerped(15, 20, level)
			end,
		},
	},

	BanditDuelist = {
		Name = "Bandit Duelist",
		Description = "An armored bandit that prefers violence over subterfuge.",
		ModelName = "BanditDuelist",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored", "Brutal" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "DuelistAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.27
			end,
			Speed = function()
				return 0.06
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(2, 2.75, level)
			end,
			HealthMax = function(level)
				return lerped(20, 31, level)
			end,
		},
	},

	SkyPirateOfficer = {
		Name = "SkyPirate Officer",
		Description = `His blades dance gracefully across the battlefield, cutting down foes in his path.`,
		ModelName = "SkyPirateOfficer",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored", "Brutal" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "DualSwordsAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.3
			end,
			Speed = function()
				return 0.15
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return scaling(10, 2, level)
			end,
			HealthMax = function(level)
				return scaling(12, 1, level)
			end,
		},
	},

	OrcWarrior = {
		Name = "Orc Warrior",
		Description = `A powerful Orcish brute clad in crude scraps of leather.`,
		ModelName = "OrcWarrior",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light", "Brutal" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "BerserkerAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.27
			end,
			Speed = function()
				return 0.04
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(2, 2.75, level)
			end,
			HealthMax = function(level)
				return lerped(20, 31, level)
			end,
		},
	},

	OrcChampion = {
		Name = "Orc Champion",
		Description = `A heavily-armored Orcish warrior. Soldiers like these are the pride of the Orcish highlands.`,
		ModelName = "OrcChampion",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored", "Brutal" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "BerserkerAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.27
			end,
			Speed = function()
				return 0.04
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return lerped(2.5, 3.25, level)
			end,
			HealthMax = function(level)
				return lerped(25, 34, level)
			end,
		},
	},

	ElfBrawler = {
		Name = "Elf Brawler",
		Description = `A lightly-armored, quick-footed soldier -- the backbone of the elven military.`,
		ModelName = "ElfBrawler",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light", "Evasive" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "BerserkerAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
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
				return 1.25
			end,
			Damage = function(level)
				return scaling(1, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(15, 2, level)
			end,
		},
	},

	ElfRanger = {
		Name = "Elf Ranger",
		Description = "A naturally gifted elven archer.",
		ModelName = "ElfRanger",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -2),
			ProjectileName = "Arrow1",
		},
		Tags = { "Ranged" },
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
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.55
			end,
			Speed = function()
				return 0.05
			end,
			Range = function()
				return 0.375
			end,
			AttackRate = function()
				return 1.25
			end,
			Damage = function(level)
				return scaling(1, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(10, 1, level)
			end,
		},
	},

	MasterMage = {
		Name = "MasterMage",
		Description = "A master of the arcane arts.",
		ModelName = "MasterMage",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0.75, -0.25),
			ProjectileName = "MagicStar1",
		},
		Tags = { "Ranged" },
		Animations = {
			Walk = "MageWalk",
			Attack = "MasterMageAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Shoot = { "WandCast1", "WandCast2", "WandCast3" },
			Hit = { "MagicImpact1", "MagicImpact2", "MagicImpact3" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.3
			end,
			Speed = function()
				return 0.05
			end,
			Range = function()
				return 0.5
			end,
			AttackRate = function()
				return 0.5
			end,
			Damage = function(level)
				return lerped(3, 3.75, level)
			end,
			HealthMax = function(level)
				return lerped(20, 25, level)
			end,
		},
	},

	Draugr = {
		Name = "Draugr",
		Description = "A fallen viking warrior held together by cursed magic.",
		ModelName = "Draugr",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light", "Evasive" },
		Animations = {
			Walk = "DraugrWalk",
			Attack = "DraugrAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "UndeadGroan2" },
		},
		Stats = {
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
				return lerped(2, 3, level)
			end,
			HealthMax = function(level)
				return lerped(20, 25, level)
			end,
		},
	},

	UndeadWarrior = {
		Name = "UndeadWarrior",
		Description = `What remains of a knight who has long since passed.`,
		ModelName = "UndeadWarrior",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored" },
		Animations = {
			Walk = "DraugrWalk",
			Attack = "DraugrAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "UndeadGroan2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 0.43
			end,
			Speed = function()
				return 0.2
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 1.2
			end,
			Damage = function(level)
				return scaling(1.7, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(6, 2, level)
			end,
		},
	},

	Cultist = {
		Name = "Cultist",
		Description = `A fanatic worshiper of the dark arts, bound to his masters will.`,
		ModelName = "Cultist",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 0, -0.25),
			ProjectileName = "DarkEnergy",
			ProjectileSpeed = 12,
		},
		Tags = { "Ranged" },
		Animations = {
			Walk = "CultistWalk",
			Attack = "CultistAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Shoot = { "WandCast4", "WandCast4", "WandCast4" },
			Hit = { "MagicImpact4", "MagicImpact4", "MagicImpact4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Stats = {
			Size = 0.03,
			AttackWindupTime = function()
				return 1
			end,
			Speed = function()
				return 0.1
			end,
			Range = function()
				return 0.6
			end,
			AttackRate = function()
				return 0.4
			end,
			Damage = function(level)
				return scaling(4, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(13, 2, level)
			end,
		},
	},

	FrostGiant = {
		Name = "Frost Giant",
		Description = `Dwelling high in the mountains, the world trembles in the wake of these massive titans.`,
		ModelName = "FrostGiant",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored", "Brutal" },
		Animations = {
			Idle = "FrostGiantIdle",
			Walk = "FrostGiantWalk",
			Attack = "FrostGiantAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "LargeThud1", "LargeThud2" },
			Death = { "GiantsRoar1", "GiantsRoar2", "GiantsRoar3" },
		},
		Stats = {
			Size = 0.04,
			AttackWindupTime = function()
				return 0.7
			end,
			Speed = function()
				return 0.05
			end,
			Range = function()
				return 0.2
			end,
			AttackRate = function()
				return 1.6
			end,
			Damage = function(level)
				return scaling(7, 0.7, level)
			end,
			HealthMax = function(level)
				return scaling(25, 2, level)
			end,
		},
	},

	Dragon = {
		Name = "Dragon",
		Description = `This giant scaly beast is a creature of legend, striking fear into the hearts of all those unfortunate enough to cross its path.`,
		ModelName = "Dragon",
		Brain = {
			Id = "BasicRanged",
			ProjectileOffset = CFrame.new(0, 7, -3.25),
			ProjectileName = "Fireball",
			ProjectileSpeed = 15,
		},
		Tags = { "Armored", "Ranged" },
		Animations = {
			Idle = "DragonIdle",
			Walk = "DragonFly",
			Attack = "DragonAttack",
			Die = "DragonDie",
		},
		Sounds = {
			Shoot = { "DragonRoar1" },
			Hit = { "MagicImpact4" },
			Death = { "DragonRoar2" },
		},
		Stats = {
			Size = 0.04,
			AttackWindupTime = function()
				return 0.8
			end,
			Speed = function()
				return 0.14
			end,
			Range = function()
				return 0.65
			end,
			AttackRate = function()
				return 0.5
			end,
			Damage = function(level)
				return scaling(15, 0.7, level)
			end,
			HealthMax = function(level)
				return scaling(30, 2, level)
			end,
		},
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
