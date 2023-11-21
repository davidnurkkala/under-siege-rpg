local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local SessionLength = 20 * 60

local Rewards = {
	{ Type = "Currency", CurrencyType = "Primary", Amount = 150 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 10 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 5 },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 310 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 15 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 10 },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 620 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 30 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 15 },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 1250 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 60 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 20 },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 2500 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 120 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 25 },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 5000 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 250 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 30 },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 10000 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 500 },
}

return Sift.Array.map(Rewards, function(reward, index)
	local scalar = index / #Rewards

	return {
		Time = math.floor((scalar ^ 2) * SessionLength),
		Reward = reward,
	}
end)
