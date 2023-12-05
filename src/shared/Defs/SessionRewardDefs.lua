local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local SessionLength = 90 * 60

local Rewards = {
	{ Type = "Currency", CurrencyType = "Primary", Amount = 150 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 10 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 5 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Primary", Multiplier = 1.5, Time = 3 * 60 } },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 310 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 15 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 10 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Secondary", Multiplier = 2, Time = 3 * 60 } },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 620 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 30 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 15 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Primary", Multiplier = 1.5, Time = 5 * 60 } },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 1250 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 60 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 20 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Secondary", Multiplier = 2, Time = 5 * 60 } },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 2500 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 120 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 25 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Primary", Multiplier = 1.5, Time = 10 * 60 } },
}

return Sift.Array.map(Rewards, function(reward, index)
	local scalar = index / #Rewards

	return {
		Time = math.floor((scalar ^ 2) * SessionLength),
		Reward = reward,
	}
end)
