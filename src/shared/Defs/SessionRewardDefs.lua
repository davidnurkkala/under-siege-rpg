local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local SessionLength = 20 * 60

local Rewards = {
	{ Type = "Currency", CurrencyType = "Primary", Amount = 100 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 10 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 5 },
	{ Type = "Currency", CurrencyType = "Primary", Amount = 1000 },
	{ Type = "Currency", CurrencyType = "Secondary", Amount = 50 },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 10 },
}

return Sift.Array.map(Rewards, function(reward, index)
	local scalar = index / #Rewards

	return {
		Time = math.floor((scalar ^ 2) * SessionLength),
		Reward = reward,
	}
end)
