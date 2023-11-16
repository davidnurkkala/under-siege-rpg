local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Cards = {
	Peasant = {
		GoonId = "Peasant",
		Type = "Goon",
		Rank = 1,
	},
	Soldier = {
		GoonId = "Peasant",
		Type = "Goon",
		Rank = 1,
	},
	Hunter = {
		GoonId = "Peasant",
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
}

return Sift.Dictionary.map(Cards, function(card, id)
	if card.Type == "Goon" then card.Name = GoonDefs[card.GoonId].Name end

	return Sift.Dictionary.merge(card, {
		Id = id,
	})
end)
