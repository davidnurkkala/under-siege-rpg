local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local SessionLength = 90 * 60

local Rewards = {
	{ Type = "Currency", CurrencyType = "Coins", Amount = 10 },
	{ Type = "Currency", CurrencyType = "SimpleFood", Amount = 5 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 1 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Coins", Multiplier = 2, Time = 3 * 60 } },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 20 },
	{ Type = "Currency", CurrencyType = "SimpleMaterials", Amount = 5 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 1 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Coins", Multiplier = 2, Time = 3 * 60 } },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 30 },
	{ Type = "Currency", CurrencyType = "CommonMetal", Amount = 5 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 1 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Coins", Multiplier = 2, Time = 5 * 60 } },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 40 },
	{ Type = "Currency", CurrencyType = "Steel", Amount = 5 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 1 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Coins", Multiplier = 2, Time = 5 * 60 } },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 50 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 5 },
}

return Sift.Array.map(Rewards, function(reward, index)
	local scalar = index / #Rewards

	return {
		Time = math.floor((scalar ^ 2) * SessionLength),
		Reward = reward,
	}
end)
