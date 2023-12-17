local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Products = {
	Vip = {
		AssetId = 673504609,
		Type = "GamePass",
	},
}

return Sift.Dictionary.map(Products, function(product, id)
	return Sift.Dictionary.merge(product, {
		Id = id,
	})
end)
