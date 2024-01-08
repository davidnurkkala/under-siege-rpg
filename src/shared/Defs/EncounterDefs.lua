local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Encounters = {
	-- World 1 Encounters
	RebelPeasant = {
		Level = 1,
		Health = 10,
		GoonId = "Peasant",
	},
	AngryMiner = {
		Level = 5,
		Health = 50,
		GoonId = "Miner",
	},
	Mercenary = {
		Level = 3,
		Health = 30,
		GoonId = "Recruit",
	},
	KnightErrant = {
		Level = 10,
		Health = 100,
		GoonId = "Footman",
	},
	FallenKnight = {
		Level = 25,
		Health = 200,
		GoonId = "Footman",
	},
}

return Sift.Dictionary.map(Encounters, function(encounter, id)
	return Sift.Dictionary.merge(encounter, {
		Id = id,
	})
end)
