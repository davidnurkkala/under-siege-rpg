local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Products = {
	Vip = {
		AssetId = 673504609,
		Type = "GamePass",
	},
	MultiRoll = {
		FreeForPremium = true,
		AssetId = 674957315,
		Type = "GamePass",
	},
	Gems50 = {
		AssetId = 1744654424,
		Type = "DeveloperProduct",
		Rewards = {
			{ Type = "Currency", CurrencyType = "Gems", Amount = 50 },
		},
	},
	Gems110 = {
		AssetId = 1744654521,
		Type = "DeveloperProduct",
		Rewards = {
			{ Type = "Currency", CurrencyType = "Gems", Amount = 110 },
		},
	},
	Gems300 = {
		AssetId = 1744654661,
		Type = "DeveloperProduct",
		Rewards = {
			{ Type = "Currency", CurrencyType = "Gems", Amount = 300 },
		},
	},
	Gems650 = {
		AssetId = 1744654782,
		Type = "DeveloperProduct",
		Rewards = {
			{ Type = "Currency", CurrencyType = "Gems", Amount = 650 },
		},
	},
	Gems1400 = {
		AssetId = 1744654885,
		Type = "DeveloperProduct",
		Rewards = {
			{ Type = "Currency", CurrencyType = "Gems", Amount = 1400 },
		},
	},
}

return Sift.Dictionary.map(Products, function(product, id)
	return Sift.Dictionary.merge(product, {
		Id = id,
	})
end)
