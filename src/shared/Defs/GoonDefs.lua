local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local function scaling(base, perLevel, level)
	return base + perLevel * (level - 1)
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
				return scaling(1, 1, level)
			end,
			HealthMax = function(level)
				return scaling(10, 1, level)
			end,
		},
	},

	Recruit = {
		Name = "Recruit",
		Description = "A regular soldier with a cheap sword and salvaged armor.",
		ModelName = "Recruit",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored", "Light" },
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
				return 0.05
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return scaling(2, 1, level)
			end,
			HealthMax = function(level)
				return scaling(15, 1, level)
			end,
		},
	},

	Footman = {
		Name = "Footman",
		Description = "A trained soldier with standard issue weapons and armor.",
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
				return 0.05
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.75
			end,
			Damage = function(level)
				return scaling(2.5, 1, level)
			end,
			HealthMax = function(level)
				return scaling(20, 1, level)
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
				return 1.1
			end,
			Damage = function(level)
				return scaling(1, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(10, 1, level)
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
		Tags = { "Charger", "Brutal" },
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
				return scaling(4, 2, level)
			end,
			HealthMax = function(level)
				return scaling(5, 1, level)
			end,
		},
	},

	BanditScout = {
		Name = "Bandit Scout",
		Description = "An Elven marksman with a keen eye, keeping watch for the guards",
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
		Size = 0.03,
		AttackWindupTime = function()
			return 0.5
		end,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.4
		end,
		AttackRate = function()
			return 1
		end,
		Damage = function(level)
			return scaling(2, 0.5, level)
		end,
		HealthMax = function(level)
			return scaling(8, 1, level)
		end,
	},

	BanditRogue = {
		Name = "Bandit Rogue",
		Description = `A sneaky fighter with a taste for ill gotten goods. Watch your pockets!`,
		ModelName = "BanditRogue",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light" },
		{ "Charger" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "RogueAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		AttackWindupTime = function()
			return 0.2
		end,
		Speed = function()
			return 0.3
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.4
		end,
		Damage = function(level)
			return scaling(6, 2, level)
		end,
		HealthMax = function(level)
			return scaling(3, 1, level)
		end,
	},

	BanditDuelist = {
		Name = "Bandit Duelist",
		Description = `A versatile and unpredictable bandit fighter.`,
		ModelName = "BanditDuelist",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "DuelistAttack",
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
			return 0.2
		end,
		Range = function()
			return 0.15
		end,
		AttackRate = function()
			return 0.55
		end,
		Damage = function(level)
			return scaling(8, 2, level)
		end,
		HealthMax = function(level)
			return scaling(10, 1, level)
		end,
	},

	BanditOfficer = {
		Name = "Bandit Officer",
		Description = `His blades dance gracefully across the battlefield, cutting down foes in his path.`,
		ModelName = "BanditOfficer",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Armored" },
		{ "Brutal" },
		Animations = {
			Walk = "SwordsmanWalk",
			Attack = "DualSwordsAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
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

	OrcWarrior = {
		Name = "Orc Warrior",
		Description = `A powerful Orcish brute clad in crude scraps of leather.`,
		ModelName = "OrcWarrior",
		Brain = {
			Id = "BasicMelee",
		},
		Tags = { "Light" },
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
				return scaling(5, 1, level)
			end,
			HealthMax = function(level)
				return scaling(15, 2, level)
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
		Tags = { "Armored" },
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
				return 0.05
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 0.25
			end,
			Damage = function(level)
				return scaling(8, 2, level)
			end,
			HealthMax = function(level)
				return scaling(20, 3, level)
			end,
		},
	},

	ElfBrawler = {
		Name = "Elf Brawler",
		Description = `A lightly-armored, quick-footed soldier -- the backbone of the Elven military.`,
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
		Description = "A naturally gifted Elven archer.",
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

	RoyalRanger = {
		Name = "Royal Ranger",
		Description = "An legendary archer sworn to serve the crown.",
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
				return 0.375
			end,
			AttackRate = function()
				return 1.25
			end,
			Damage = function(level)
				return scaling(3, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(18, 1, level)
			end,
		},
	},

	RoyalGuard = {
		Name = "Royal Guard",
		Description = `A plate armor clad knight and a master of martial combat.`,
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
				return 0.43
			end,
			Speed = function()
				return 0.07
			end,
			Range = function()
				return 0.1
			end,
			AttackRate = function()
				return 1.25
			end,
			Damage = function(level)
				return scaling(2, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(25, 2, level)
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
				return 0.45
			end,
			AttackRate = function()
				return 0.3
			end,
			Damage = function(level)
				return scaling(4, 0.75, level)
			end,
			HealthMax = function(level)
				return scaling(7, 1, level)
			end,
		},
	},

	RoyalCavalry = {
		Name = "Royal Cavalry",
		Description = `A mounted knight armed with a deadly lance and a thirst for battle.`,
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
				return scaling(4, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(30, 2, level)
			end,
		},
	},

	Draugr = {
		Name = "Draugr",
		Description = `A fallen viking warrior held together by cursed magicks.`,
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
				return scaling(2, 0.5, level)
			end,
			HealthMax = function(level)
				return scaling(7, 2, level)
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
