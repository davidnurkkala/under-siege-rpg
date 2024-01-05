local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Encounters = {
	RebelPeasant = {
		Level = 1,
		Health = 10,
		GoonId = "Peasant",
	},
	KnightErrant = {
		Level = 10,
		Health = 100,
		GoonId = "Footman",
	},
}

return Sift.Dictionary.map(Encounters, function(encounter, id)
	return Sift.Dictionary.merge(encounter, {
		Id = id,
	})
end)
