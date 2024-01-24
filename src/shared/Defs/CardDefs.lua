local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Cards = {
	-- GOONS
	Peasant = {
		GoonId = "Peasant",
		Type = "Goon",
		Rank = 1,
		Cooldown = 1,
		Cost = 10,
		Upgrades = {
			{
				Coins = 10,
				SimpleFood = 5,
			},
			{
				Coins = 50,
				SimpleFood = 10,
				SimpleMaterials = 5,
			},
			{
				Coins = 200,
				SimpleFood = 50,
				SimpleMaterials = 25,
			},
			{
				Coins = 1000,
				SimpleFood = 100,
				SimpleMaterials = 50,
			},
		},
	},
	Recruit = {
		GoonId = "Recruit",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
		Cost = 20,
	},
	Footman = {
		GoonId = "Footman",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
		Cost = 30,
	},
	Miner = {
		GoonId = "Miner",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
		Cost = 15,
	},
	Hunter = {
		GoonId = "Hunter",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
		Cost = 15,
	},
	Demolitionist = {
		GoonId = "Demolitionist",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
		Cost = 50,
	},
	PickaxeThrower = {
		GoonId = "PickaxeThrower",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
		Cost = 30,
	},
	Mage = {
		GoonId = "Mage",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
		Cost = 50,
	},
	BanditScout = {
		GoonId = "BanditScout",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
		Cost = 25,
	},
	BanditRogue = {
		GoonId = "Mage",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
		Cost = 25,
	},
	BanditDuelist = {
		GoonId = "BanditDuelist",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
		Cost = 25,
	},
	BanditOfficer = {
		GoonId = "BanditOfficer",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
		Cost = 25,
	},
	Berserker = {
		GoonId = "Berserker",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
		Cost = 25,
	},
	VikingWarrior = {
		GoonId = "VikingWarrior",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
		Cost = 25,
	},
	ElfRanger = {
		GoonId = "ElfRanger",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
		Cost = 30,
	},
	ElfBrawler = {
		GoonId = "ElfBrawler",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
		Cost = 30,
	},
	OrcWarrior = {
		GoonId = "OrcWarrior",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
		Cost = 30,
	},
	OrcChampion = {
		GoonId = "OrcChampion",
		Type = "Goon",
		Rank = 1,
		Cooldown = 5,
		Cost = 50,
	},

	-- ABILITIES
	Heal = {
		AbilityId = "Heal",
		Type = "Ability",
		Rank = 1,
		Cooldown = 3,
		Cost = 10,
	},
	RainOfArrows = {
		AbilityId = "RainOfArrows",
		Type = "Ability",
		Rank = 1,
		Cooldown = 3,
		Cost = 20,
	},
	Recruitment = {
		AbilityId = "Recruitment",
		Type = "Ability",
		Rank = 1,
		Cooldown = 4,
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
