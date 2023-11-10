local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

export type Price = {
	[CurrencyDefs.CurrencyType]: number,
}

export type Wallet = {
	[CurrencyDefs.CurrencyType]: number,
}

local CurrencyHelper = {}

function CurrencyHelper.CheckPrice(wallet: Wallet, price: Price)
	return Sift.Dictionary.every(price, function(currencyType, amount)
		return wallet[currencyType] >= amount
	end)
end

return CurrencyHelper
