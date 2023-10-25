local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
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
		local promise = DataService:GetSaveFile(player):andThen(function(saveFile)
			saveFile:Observe("Currency", function(currency)
				self.CurrencyRemote:SetFor(player, currency)
			end)
		end)

		return function()
			promise:cancel()
		end
	end)
end

function CurrencyService.AddCurrency(_self: CurrencyService, player: Player, currencyType: string, amount: number)
	assert(Sift.Dictionary.has(CurrencyDefs, currencyType), `Invalid currency type {currencyType}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Currency", function(oldCurrency)
			return Sift.Dictionary.set(oldCurrency, currencyType, oldCurrency[currencyType] + amount)
		end)
	end)
end

function CurrencyService.Start(self: CurrencyService) end

return CurrencyService
