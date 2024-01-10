local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Tags = {
	Light = {
		Name = "Light",
		Description = "Deals extra damage to Armored enemies.",
	},
	Ranged = {
		Name = "Ranged",
		Description = "Deals slightly more damage to Light enemies.",
	},
	Armored = {
		Name = "Armored",
		Description = "Takes significantly less damage from Ranged enemies.",
	},
	Evasive = {
		Name = "Evasive",
		Description = "Has a chance of avoiding attacks from Ranged enemies.",
	},
	Charger = {
		Name = "Charger",
		Description = "Moves much faster until first attack.",
	},
	Brutal = {
		Name = "Brutal",
		Description = "First damage dealt is dramatically increased.",
	},
}

return Sift.Dictionary.map(Tags, function(tag, id)
	return Sift.Dictionary.merge(tag, {
		Id = id,
	})
end)
