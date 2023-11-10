local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyHelper = require(ReplicatedStorage.Shared.Util.CurrencyHelper)

local CurrencyController = {
	Priority = 0,
}

type CurrencyController = typeof(CurrencyController)

function CurrencyController.PrepareBlocking(self: CurrencyController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "CurrencyService")
	self.CurrencyRemote = self.Comm:GetProperty("Currency")
end

function CurrencyController.CheckPrice(self: CurrencyController, price: CurrencyHelper.Price)
	return CurrencyHelper.CheckPrice(self.CurrencyRemote:Get(), price)
end

return CurrencyController
