local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

export type Price = {
	[string]: number,
}

export type Wallet = {
	[string]: number,
}

local CurrencyHelper = {}

function CurrencyHelper.CheckPrice(wallet: Wallet, price: Price)
	return Sift.Dictionary.every(price, function(amount, currencyType)
		return wallet[currencyType] >= amount
	end)
end

return CurrencyHelper
