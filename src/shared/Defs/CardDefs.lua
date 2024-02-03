local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Cards = {
	-- GOONS

	-- tier 0
	Peasant = {
		Type = "Goon",
		GoonId = "Peasant",
		Rank = 0,
		Cooldown = 5,
		Cost = 10,
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
		Cooldown = 5,
		Cost = 15,
	},
	Militia = {
		Type = "Goon",
		GoonId = "Militia",
		Rank = 0,
		Cooldown = 5,
		Cost = 20,
	},

	-- tier 1
	Spearman = {
		Type = "Goon",
		GoonId = "Spearman",
		Rank = 1,
		Cooldown = 5,
		Cost = 15,
	},
	Archer = {
		Type = "Goon",
		GoonId = "Archer",
		Rank = 1,
		Cooldown = 5,
		Cost = 20,
	},
	Recruit = {
		Type = "Goon",
		GoonId = "Recruit",
		Rank = 1,
		Cooldown = 5,
		Cost = 25,
	},

	-- tier 2
	Pikeman = {
		Type = "Goon",
		GoonId = "Pikeman",
		Rank = 2,
		Cooldown = 5,
		Cost = 20,
	},
	Crossbowman = {
		Type = "Goon",
		GoonId = "Crossbowman",
		Rank = 2,
		Cooldown = 5,
		Cost = 25,
	},
	Footman = {
		Type = "Goon",
		GoonId = "Footman",
		Rank = 3,
		Cooldown = 5,
		Cost = 30,
	},

	-- tier 3
	RoyalGuard = {
		Type = "Goon",
		GoonId = "RoyalGuard",
		Rank = 3,
		Cooldown = 5,
		Cost = 50,
	},
	RoyalRanger = {
		Type = "Goon",
		GoonId = "RoyalRanger",
		Rank = 3,
		Cooldown = 5,
		Cost = 50,
	},
	RoyalCavalry = {
		Type = "Goon",
		GoonId = "RoyalCavalry",
		Rank = 3,
		Cooldown = 10,
		Cost = 75,
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
	BanditScout = {
		Type = "Goon",
		GoonId = "BanditScout",
		Rank = 1,
		Cooldown = 6,
		Cost = 25,
	},
	BanditRogue = {
		Type = "Goon",
		GoonId = "Mage",
		Rank = 1,
		Cooldown = 6,
		Cost = 25,
	},
	BanditDuelist = {
		Type = "Goon",
		GoonId = "BanditDuelist",
		Rank = 1,
		Cooldown = 5,
		Cost = 25,
	},
	BanditOfficer = {
		Type = "Goon",
		GoonId = "BanditOfficer",
		Rank = 1,
		Cooldown = 4,
		Cost = 25,
	},
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

	-- ABILITIES
	Heal = {
		Type = "Ability",
		AbilityId = "Heal",
		Rank = 1,
		Cooldown = 5,
		Cost = 10,
	},
	RainOfArrows = {
		Type = "Ability",
		AbilityId = "RainOfArrows",
		Rank = 1,
		Cooldown = 5,
		Cost = 20,
	},
	Recruitment = {
		Type = "Ability",
		AbilityId = "Recruitment",
		Rank = 1,
		Cooldown = 6,
		Cost = 50,
	},
}

return Sift.Dictionary.map(Cards, function(card, id)
	if card.Type == "Goon" then card.Name = GoonDefs[card.GoonId].Name end
	if card.Type == "Ability" then card.Name = AbilityHelper.GetAbility(card.AbilityId).Name end

	return Sift.Dictionary.merge(card, {
		Id = id,
	})
end)
