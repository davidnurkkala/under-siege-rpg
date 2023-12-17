local Rewards = {
	{ Type = "Currency", CurrencyType = "Premium", Amount = 10 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Primary", Multiplier = 2, Time = 10 * 60 } },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Secondary", Multiplier = 2, Time = 10 * 60 } },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 50 },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Primary", Multiplier = 2, Time = 10 * 60 } },
	{ Type = "Boost", Boost = { Type = "Currency", CurrencyType = "Secondary", Multiplier = 2, Time = 10 * 60 } },
	{ Type = "Currency", CurrencyType = "Premium", Amount = 100 },
}

return Rewards
