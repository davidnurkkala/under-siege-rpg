local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BoostService = require(ServerScriptService.Server.Services.BoostService)
local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local CurrencyHelper = require(ReplicatedStorage.Shared.Util.CurrencyHelper)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ProductHelper = require(ReplicatedStorage.Shared.Util.ProductHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)

local CurrencyService = {
	Priority = 0,
}

type CurrencyService = typeof(CurrencyService)

function CurrencyService.PrepareBlocking(self: CurrencyService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "CurrencyService")

	self.CurrencyRemote = self.Comm:CreateProperty(
		"Currency",
		Sift.Dictionary.map(CurrencyDefs, function()
			return 0
		end)
	)

	Observers.observePlayer(function(player)
		return DataService:ObserveKey(player, "Currency", function()
			local promise = self:GetWallet(player):andThen(function(wallet)
				self.CurrencyRemote:SetFor(player, wallet)
			end)

			return function()
				promise:cancel()
			end
		end)
	end)
end

function CurrencyService.GetCurrency(self: CurrencyService, player: Player, currencyType: string)
	assert(Sift.Dictionary.has(CurrencyDefs, currencyType), `Invalid currency type {currencyType}`)

	return self:GetWallet(player):andThen(function(wallet)
		return wallet[currencyType]
	end)
end

function CurrencyService.SetCurrency(_self: CurrencyService, player: Player, currencyType: string, amount: number)
	assert(Sift.Dictionary.has(CurrencyDefs, currencyType), `Invalid currency type {currencyType}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Currency", function(oldCurrency)
			return Sift.Dictionary.set(oldCurrency, currencyType, amount)
		end)
	end)
end

function CurrencyService.GetWallet(_self: CurrencyService, player: Player)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local ownedCurrency = saveFile:Get("Currency")

		return Sift.Dictionary.map(CurrencyDefs, function(_, currencyType)
			return ownedCurrency[currencyType] or 0
		end)
	end)
end

function CurrencyService.GetBoosted(_self: CurrencyService, player: Player, currencyType: string, amount: number)
	return BoostService:GetMultiplier(player, function(boost)
		return (boost.Type == "Currency") and (boost.CurrencyType == currencyType)
	end):andThen(function(multiplier)
		if (currencyType == "Coins") and ProductHelper.IsVip(player) then
			multiplier += 0.1
		end

		return math.round(amount * multiplier)
	end)
end

function CurrencyService.AddCurrency(_self: CurrencyService, player: Player, currencyType: string, amount: number)
	assert(Sift.Dictionary.has(CurrencyDefs, currencyType), `Invalid currency type {currencyType}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Currency", function(currency)
			return Sift.Dictionary.update(currency, currencyType, function(current)
				return current + amount
			end, function()
				return amount
			end)
		end)

		EventStream.Event({

			Kind = "CurrencyAdded",
			Player = player,
			CurrencyType = currencyType,
			Amount = amount,
		})

		return amount
	end)
end

function CurrencyService.HasCurrency(self: CurrencyService, player: Player, currencyType: string, amount: number)
	return self:GetCurrency(player, currencyType):andThen(function(current)
		return current >= amount
	end)
end

function CurrencyService.CheckPrice(self: CurrencyService, player: Player, price: CurrencyHelper.Price)
	return self:GetWallet(player):andThen(function(wallet)
		return CurrencyHelper.CheckPrice(wallet, price)
	end)
end

function CurrencyService.ApplyPrice(self: CurrencyService, player: Player, price: CurrencyHelper.Price)
	return self:CheckPrice(player, price):andThen(function(hasCurrency)
		if not hasCurrency then return false end

		return DataService:GetSaveFile(player):andThen(function(saveFile)
			saveFile:Update("Currency", function(oldCurrency)
				return Sift.Dictionary.map(oldCurrency, function(amount, currencyType)
					if price[currencyType] then
						return amount - price[currencyType]
					else
						return amount
					end
				end)
			end)
			return true
		end)
	end)
end

return CurrencyService
