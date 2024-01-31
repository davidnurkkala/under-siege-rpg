local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Shops = {
	-- PREMIUM
	PremiumWeapons = {
		Name = "Premium Weapons",
		OverheadLabel = "Shop",
		Products = {
			{
				Reward = { Type = "Weapon", WeaponId = "ArcaneRod" },
				Price = { Gems = 150 },
			},
			{
				Reward = { Type = "Weapon", WeaponId = "WillowCrossbow" },
				Price = { Gems = 50 },
			},
		},
	},

	PremiumBases = {
		Name = "Premium Bases",
		Overhead = "Shop",
		Products = {},
	},

	-- IN-GAME
	World1Merchant = {
		Name = "Jim's Wares",
		OverheadLabel = "Shop",
		Products = {
			{
				Reward = { Type = "Currency", CurrencyType = "SimpleFood", Amount = 5 },
				Price = { Coins = 25 },
			},
			{
				Reward = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = 5 },
				Price = { Coins = 50 },
			},
			{
				Reward = { Type = "Card", CardId = "RainOfArrows" },
				Price = { Coins = 100, Gems = 25 },
			},
			{
				Reward = { Type = "Weapon", WeaponId = "HuntersBow" },
				Price = { Coins = 1000 },
			},
			{
				Reward = { Type = "Weapon", WeaponId = "Crossbow" },
				Price = { Coins = 1000 },
			},
			{
				Reward = { Type = "Weapon", WeaponId = "SimpleWand" },
				Price = { Coins = 1000 },
			},
		},
	},
	World1Mage = {
		Name = "Atraeus' Emporium",
		OverheadLabel = "Shop",
		Products = {
			{
				Reward = { Type = "Currency", CurrencyType = "Gems", Amount = 1 },
				Price = { Coins = 1000 },
			},
		},
	},
}

return Sift.Dictionary.map(Shops, function(shop, id)
	return Sift.Dictionary.merge(shop, {
		Id = id,
		Products = Sift.Array.map(shop.Products, function(product, index)
			return Sift.Dictionary.merge(product, {
				Index = index,
			})
		end),
	})
end)
