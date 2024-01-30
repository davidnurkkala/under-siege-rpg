local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Shops = {
	World1Merchant = {
		Name = "Jim's Wares",
		OverheadLabel = "Shop",
		Products = {
			{
				Price = { Coins = 25 },
				Reward = { Type = "Currency", CurrencyType = "SimpleFood", Amount = 5 },
			},
			{
				Price = { Coins = 50 },
				Reward = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = 5 },
			},
			{
				Price = { Coins = 100, Gems = 25 },
				Reward = { Type = "Card", CardId = "RainOfArrows" },
			},
		},
	},
	World1Mage = {
		Name = "Atraeus' Emporium",
		OverheadLabel = "Shop",
		Products = {
			{
				Price = { Coins = 1000 },
				Reward = { Type = "Currency", CurrencyType = "Gems", Amount = 1 },
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
