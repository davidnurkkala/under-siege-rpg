local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Cards = {
	Conscript = {
		GoonId = "Conscript",
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
