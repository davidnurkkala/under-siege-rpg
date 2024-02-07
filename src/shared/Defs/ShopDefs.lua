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
		Products = {
			{
				Reward = { Type = "Cosmetic", CategoryName = "Bases", Id = "VikingPalisade" },
				Price = { Gems = 250 },
			},
			{
				Reward = { Type = "Cosmetic", CategoryName = "Bases", Id = "ElvenKeep" },
				Price = { Gems = 250 },
			},

			{
				Reward = { Type = "Cosmetic", CategoryName = "Bases", Id = "Grim" },
				Price = { Gems = 300 },
			},

			{
				Reward = { Type = "Cosmetic", CategoryName = "Bases", Id = "Sandstone" },
				Price = { Gems = 250 },
			},

			{
				Reward = { Type = "Cosmetic", CategoryName = "Bases", Id = "Peaked" },
				Price = { Gems = 250 },
			},

			{
				Reward = { Type = "Cosmetic", CategoryName = "Bases", Id = "OldCastle" },
				Price = { Gems = 250 },
			},

			{
				Reward = { Type = "Cosmetic", CategoryName = "Bases", Id = "ClassicReborn" },
				Price = { Gems = 250 },
			},
		},
	},

	PremiumGems = {
		Name = "Gems",
		Overhead = "Shop",
		Products = {
			-- defined in ProductDefs, this def is here for automation
		},
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
				Reward = { Type = "Weapon", WeaponId = "HuntersBow" },
				Price = { Coins = 1000 },
			},
		},
	},
	World1Mage = {
		Name = "Atraeus' Emporium",
		OverheadLabel = "Shop",
		Products = {
			{
				Reward = { Type = "Weapon", WeaponId = "SimpleWand" },
				Price = { Coins = 1000 },
			},
			{
				Reward = { Type = "Card", CardId = "Heal" },
				Price = { Coins = 2500 },
			},
			{
				Reward = { Type = "Card", CardId = "Fireball" },
				Price = { Coins = 10000 },
			},
		},
	},
	World1Guildmaster = {
		Name = "Kutz' Mercenary Guild",
		OverheadLabel = "Shop",
		Products = {
			{
				Reward = { Type = "Card", CardId = "Spearman" },
				Price = { Coins = 2000 },
			},
			{
				Reward = { Type = "Card", CardId = "Archer" },
				Price = { Coins = 2500 },
			},
			{
				Reward = { Type = "Card", CardId = "Recruit" },
				Price = { Coins = 3000 },
			},
			{
				Reward = { Type = "Weapon", WeaponId = "Crossbow" },
				Price = { Coins = 1000 },
			},
			{
				Reward = { Type = "Card", CardId = "RainOfArrows" },
				Price = { Coins = 3000 },
			},
		},
	},
	World1Blacksmith = {
		Name = "Kenny's Smithy",
		OverheadLabel = "Blacksmith",
		Products = {
			{
				Reward = { Type = "Currency", CurrencyType = "CommonMetal", Amount = 3 },
				Price = { CommonOre = 5 },
			},
			{
				Reward = { Type = "Currency", CurrencyType = "Steel", Amount = 1 },
				Price = { CommonMetal = 3, Coal = 1 },
			},
			{
				Reward = { Type = "Currency", CurrencyType = "Steel", Amount = 1 },
				Price = { CommonMetal = 3, Charcoal = 3 },
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
