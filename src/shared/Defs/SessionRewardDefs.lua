local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local SessionLength = 90 * 60

local Rewards = {
	{ Type = "Currency", CurrencyType = "Coins", Amount = 150 },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 10 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 5 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Coins", Multiplier = 1.5, Time = 3 * 60 } },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 310 },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 15 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 10 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Coins", Multiplier = 2, Time = 3 * 60 } },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 620 },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 30 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 15 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Coins", Multiplier = 1.5, Time = 5 * 60 } },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 1250 },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 60 },
	{ Type = "Currency", CurrencyType = "Gems", Amount = 20 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Coins", Multiplier = 2, Time = 5 * 60 } },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 2500 },
	{ Type = "Currency", CurrencyType = "Coins", Amount = 120 },
}

return Sift.Array.map(Rewards, function(reward, index)
	local scalar = index / #Rewards

	return {
		Time = math.floor((scalar ^ 2) * SessionLength),
		Reward = reward,
	}
end)
