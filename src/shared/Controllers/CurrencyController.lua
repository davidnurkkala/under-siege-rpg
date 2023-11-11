local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyHelper = require(ReplicatedStorage.Shared.Util.CurrencyHelper)
local Trove = require(ReplicatedStorage.Packages.Trove)

local CurrencyController = {
	Priority = 0,
}

type CurrencyController = typeof(CurrencyController)

function CurrencyController.PrepareBlocking(self: CurrencyController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "CurrencyService")
	self.CurrencyRemote = self.Comm:GetProperty("Currency")
end

function CurrencyController:ObserveCurrency(callback)
	local connection = self.CurrencyRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

function CurrencyController.CheckPrice(self: CurrencyController, price: CurrencyHelper.Price)
	return self.CurrencyRemote:OnReady():andThen(function(currency)
		CurrencyHelper.CheckPrice(currency, price)
	end)
end

return CurrencyController
