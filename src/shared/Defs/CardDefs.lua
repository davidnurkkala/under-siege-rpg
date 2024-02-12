local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityDefs = require(ReplicatedStorage.Shared.Defs.AbilityDefs)
local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local Configuration = require(ReplicatedStorage.Shared.Configuration)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Cards = {
	-- GOONS

	-- tier 0
	Peasant = {
		Type = "Goon",
		GoonId = "Peasant",
		Rank = 0,
		Cooldown = 1,
		CostTime = 7,
		Upgrades = {
			{ Coins = 10, SimpleFood = 5 },
			{ Coins = 50, SimpleFood = 10, SimpleMaterials = 5 },
			{ Coins = 200, SimpleFood = 50, SimpleMaterials = 25 },
		},
	},
	Hunter = {
		Type = "Goon",
		GoonId = "Hunter",
		Rank = 0,
		Cooldown = 1,
		CostTime = 7,
		Upgrades = {
			{ Coins = 50, SimpleFood = 5 },
			{ Coins = 100, SimpleFood = 10, SimpleMaterials = 10 },
			{ Coins = 250, SimpleFood = 50, SimpleMaterials = 30 },
		},
	},
	Militia = {
		Type = "Goon",
		GoonId = "Militia",
		Rank = 0,
		Cooldown = 1,
		CostTime = 8,
		Upgrades = {
			{ Coins = 100, SimpleFood = 5, SimpleMaterials = 5, CommonMetal = 5 },
			{ Coins = 250, SimpleFood = 15, SimpleMaterials = 15, CommonMetal = 10 },
			{ Coins = 500, SimpleFood = 50, SimpleMaterials = 50, CommonMetal = 25 },
		},
	},

	-- tier 1
	Spearman = {
		Type = "Goon",
		GoonId = "Spearman",
		Rank = 1,
		Cooldown = 1,
		CostTime = 8,
	},
	MountedSpearman = {
		Type = "Goon",
		GoonId = "MountedSpearman",
		Rank = 1,
		Cooldown = 1,
		CostTime = 10,
	},
	Archer = {
		Type = "Goon",
		GoonId = "Archer",
		Rank = 1,
		Cooldown = 1,
		CostTime = 8,
	},
	Recruit = {
		Type = "Goon",
		GoonId = "Recruit",
		Rank = 1,
		Cooldown = 1,
		CostTime = 9,
	},

	-- tier 2
	Pikeman = {
		Type = "Goon",
		GoonId = "Pikeman",
		Rank = 2,
		Cooldown = 1,
		CostTime = 9,
	},
	Crossbowman = {
		Type = "Goon",
		GoonId = "Crossbowman",
		Rank = 2,
		Cooldown = 1,
		CostTime = 9,
	},
	Footman = {
		Type = "Goon",
		GoonId = "Footman",
		Rank = 3,
		Cooldown = 1,
		CostTime = 10,
	},

	-- tier 3
	RoyalGuard = {
		Type = "Goon",
		GoonId = "RoyalGuard",
		Rank = 3,
		Cooldown = 1,
		CostTime = 10,
	},
	RoyalRanger = {
		Type = "Goon",
		GoonId = "RoyalRanger",
		Rank = 3,
		Cooldown = 1,
		CostTime = 10,
	},
	RoyalCavalry = {
		Type = "Goon",
		GoonId = "RoyalCavalry",
		Rank = 3,
		Cooldown = 1,
		CostTime = 12,
	},

	-- bandits (tier 1)
	Bandit = {
		Type = "Goon",
		GoonId = "Bandit",
		Rank = 1,
		Cooldown = 1,
		CostTime = 8,
		Upgrades = {
			{ Coins = 50, SimpleFood = 25 },
			{ Coins = 250, SimpleFood = 50, SimpleMaterials = 25 },
			{ Coins = 1000, SimpleFood = 100, SimpleMaterials = 100 },
		},
	},
	BanditScout = {
		Type = "Goon",
		GoonId = "BanditScout",
		Rank = 1,
		Cooldown = 1,
		CostTime = 8,
		Upgrades = {
			{ Coins = 50, SimpleFood = 30 },
			{ Coins = 350, SimpleFood = 60, SimpleMaterials = 40 },
			{ Coins = 1250, SimpleFood = 150, SimpleMaterials = 150 },
		},
	},
	BanditDuelist = {
		Type = "Goon",
		GoonId = "BanditDuelist",
		Rank = 1,
		Cooldown = 1,
		CostTime = 9,
		Upgrades = {
			{ Coins = 200, SimpleFood = 50, CommonMetal = 25 },
			{ Coins = 400, SimpleFood = 100, SimpleMaterials = 25, CommonMetal = 30 },
			{ Coins = 1600, SimpleFood = 200, SimpleMaterials = 50, CommonMetal = 50 },
		},
	},
	BanditRogue = {
		Type = "Goon",
		GoonId = "BanditRogue",
		Rank = 1,
		Cooldown = 1,
		CostTime = 9,
		Upgrades = {
			{ Coins = 50, SimpleFood = 30 },
			{ Coins = 350, SimpleFood = 60, SimpleMaterials = 40 },
			{ Coins = 1250, SimpleFood = 150, SimpleMaterials = 150 },
		},
	},

	-- other units
	Miner = {
		Type = "Goon",
		GoonId = "Miner",
		Rank = 1,
		Cooldown = 4,
		Cost = 15,
	},
	Demolitionist = {
		Type = "Goon",
		GoonId = "Demolitionist",
		Rank = 1,
		Cooldown = 5,
		Cost = 50,
	},
	PickaxeThrower = {
		Type = "Goon",
		GoonId = "PickaxeThrower",
		Rank = 1,
		Cooldown = 4,
		Cost = 30,
	},
	Mage = {
		Type = "Goon",
		GoonId = "Mage",
		Rank = 1,
		Cooldown = 5,
		Cost = 50,
	},
	--[[BanditOfficer = {
		Type = "Goon",
		GoonId = "BanditOfficer",
		Rank = 1,
		Cooldown = 4,
		Cost = 25,
	},]]
	Berserker = {
		Type = "Goon",
		GoonId = "Berserker",
		Rank = 1,
		Cooldown = 5,
		Cost = 25,
	},
	VikingWarrior = {
		Type = "Goon",
		GoonId = "VikingWarrior",
		Rank = 1,
		Cooldown = 5,
		Cost = 25,
	},
	ElfRanger = {
		Type = "Goon",
		GoonId = "ElfRanger",
		Rank = 1,
		Cooldown = 6,
		Cost = 30,
	},
	ElfBrawler = {
		Type = "Goon",
		GoonId = "ElfBrawler",
		Rank = 1,
		Cooldown = 6,
		Cost = 30,
	},
	OrcWarrior = {
		Type = "Goon",
		GoonId = "OrcWarrior",
		Rank = 1,
		Cooldown = 6,
		Cost = 30,
	},
	OrcChampion = {
		Type = "Goon",
		GoonId = "OrcChampion",
		Rank = 1,
		Cooldown = 7,
		Cost = 50,
	},
	MasterMage = {
		Type = "Goon",
		GoonId = "MasterMage",
		Rank = 1,
		Cooldown = 6,
		Cost = 100,
	},
	Draugr = {
		Type = "Goon",
		GoonId = "Draugr",
		Rank = 1,
		Cooldown = 4,
		Cost = 60,
	},
	UndeadWarrior = {
		GoonId = "UndeadWarrior",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
		Cost = 40,
	},
	Cultist = {
		GoonId = "Cultist",
		Type = "Goon",
		Rank = 1,
		Cooldown = 6,
		Cost = 80,
	},
	Dragon = {
		GoonId = "Dragon",
		Type = "Goon",
		Rank = 1,
		Cooldown = 5,
		Cost = 65,
	},
	FrostGiant = {
		GoonId = "FrostGiant",
		Type = "Goon",
		Rank = 1,
		Cooldown = 5,
		Cost = 65,
	},

	-- ABILITIES
	Heal = {
		Type = "Ability",
		AbilityId = "Heal",
		Rank = 1,
		Cooldown = 10,
		CostTime = 3,
	},
	RainOfArrows = {
		Type = "Ability",
		AbilityId = "RainOfArrows",
		Rank = 1,
		Cooldown = 15,
		CostTime = 3,
	},
	Fireball = {
		Type = "Ability",
		AbilityId = "Fireball",
		Rank = 1,
		Cooldown = 1,
		CostTime = 5,
	},
	Recruitment = {
		Type = "Ability",
		AbilityId = "Recruitment",
		Rank = 1,
		Cooldown = 6,
		Cost = 50,
	},
	CheatMoreSupplies = {
		Type = "Ability",
		AbilityId = "CheatMoreSupplies",
		Rank = 69,
		Cooldown = 1,
		Cost = 0,
	},
}

return Sift.Dictionary.map(Cards, function(card, id)
	if card.Type == "Goon" then
		assert(GoonDefs[card.GoonId], `{id} has bad goon id`)
		card.Name = GoonDefs[card.GoonId].Name
	end
	if card.Type == "Ability" then
		assert(AbilityDefs[card.AbilityId], `{id} has bad ability id`)
		card.Name = AbilityHelper.GetAbility(card.AbilityId).Name
	end

	if card.CostTime then
		card.Cost = card.CostTime * Configuration.SuppliesGain
		card.CostTime = nil
	end

	return Sift.Dictionary.merge(card, {
		Id = id,
	})
end)
