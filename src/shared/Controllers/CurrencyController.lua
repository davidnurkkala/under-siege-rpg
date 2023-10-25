local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local CurrencyController = {
	Priority = 0,
}

type CurrencyController = typeof(CurrencyController)

function CurrencyController.PrepareBlocking(self: CurrencyController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "CurrencyService")
	self.CurrencyRemote = self.Comm:GetProperty("Currency")
end

function CurrencyController.Start(self: CurrencyController) end

return CurrencyController
