local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Cards = {
	Peasant = {
		GoonId = "Peasant",
		Type = "Goon",
		Rank = 1,
	},
	Recruit = {
		GoonId = "Recruit",
		Type = "Goon",
		Rank = 1,
	},
	Footman = {
		GoonId = "Footman",
		Type = "Goon",
		Rank = 1,
	},
	Hunter = {
		GoonId = "Hunter",
		Type = "Goon",
		Rank = 1,
	},
	Mage = {
		GoonId = "Mage",
		Type = "Goon",
		Rank = 1,
	},
	Berserker = {
		GoonId = "Berserker",
		Type = "Goon",
		Rank = 1,
	},
	VikingWarrior = {
		GoonId = "VikingWarrior",
		Type = "Goon",
		Rank = 1,
	},
	ElfRanger = {
		GoonId = "ElfRanger",
		Type = "Goon",
		Rank = 1,
	},
	ElfBrawler = {
		GoonId = "ElfBrawler",
		Type = "Goon",
		Rank = 1,
	},
	OrcWarrior = {
		GoonId = "OrcWarrior",
		Type = "Goon",
		Rank = 1,
	},
	OrcChampion = {
		GoonId = "OrcChampion",
		Type = "Goon",
		Rank = 1,
	},
}

return Sift.Dictionary.map(Cards, function(card, id)
	if card.Type == "Goon" then card.Name = GoonDefs[card.GoonId].Name end

	return Sift.Dictionary.merge(card, {
		Id = id,
	})
end)
