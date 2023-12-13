local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

export type Price = {
	[string]: number,
}

export type Wallet = {
	[string]: number,
}

local CurrencyHelper = {}

function CurrencyHelper.CheckPrice(wallet: Wallet, price: Price, multiplier: number?)
	if multiplier == nil then multiplier = 1 end

	return Sift.Dictionary.every(price, function(amount, currencyType)
		return wallet[currencyType] >= amount * multiplier
	end)
end

return CurrencyHelper
