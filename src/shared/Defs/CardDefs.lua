local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Cards = {
	-- SPECIAL
	Nothing = {
		AbilityId = "Nothing",
		Type = "Ability",
		Rank = 1,
		Cooldown = 1,
	},

	-- GOONS
	Peasant = {
		GoonId = "Peasant",
		Type = "Goon",
		Rank = 1,
		Cooldown = 1,
	},
	Recruit = {
		GoonId = "Recruit",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
	},
	Footman = {
		GoonId = "Footman",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
	},
	Miner = {
		GoonId = "Miner",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
	},
	Hunter = {
		GoonId = "Hunter",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
	},
	Demolitionist = {
		GoonId = "Demolitionist",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
	},
	PickaxeThrower = {
		GoonId = "PickaxeThrower",
		Type = "Goon",
		Rank = 1,
		Cooldown = 2,
	},
	Mage = {
		GoonId = "Mage",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
	},
	Berserker = {
		GoonId = "Berserker",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
	},
	VikingWarrior = {
		GoonId = "VikingWarrior",
		Type = "Goon",
		Rank = 1,
		Cooldown = 3,
	},
	ElfRanger = {
		GoonId = "ElfRanger",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
	},
	ElfBrawler = {
		GoonId = "ElfBrawler",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
	},
	OrcWarrior = {
		GoonId = "OrcWarrior",
		Type = "Goon",
		Rank = 1,
		Cooldown = 4,
	},
	OrcChampion = {
		GoonId = "OrcChampion",
		Type = "Goon",
		Rank = 1,
		Cooldown = 5,
	},

	-- ABILITIES
	Heal = {
		AbilityId = "Heal",
		Type = "Ability",
		Rank = 1,
		Cooldown = 2,
	},
	RainOfArrows = {
		AbilityId = "RainOfArrows",
		Type = "Ability",
		Rank = 1,
		Cooldown = 3,
	},
	Mob = {
		AbilityId = "Mob",
		Type = "Ability",
		Rank = 1,
		Cooldown = 4,
	},
	Recruitment = {
		AbilityId = "Recruitment",
		Type = "Ability",
		Rank = 1,
		Cooldown = 4,
	},
}

return Sift.Dictionary.map(Cards, function(card, id)
	if card.Type == "Goon" then card.Name = GoonDefs[card.GoonId].Name end
	if card.Type == "Ability" then card.Name = AbilityHelper.GetAbility(card.AbilityId).Name end

	return Sift.Dictionary.merge(card, {
		Id = id,
	})
end)
