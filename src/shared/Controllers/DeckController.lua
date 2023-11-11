local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DeckController = {
	Priority = 0,
}

type DeckController = typeof(DeckController)

function DeckController.PrepareBlocking(self: DeckController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "DeckService")

	self.DrawCardFromGachaRemote = self.Comm:GetFunction("DrawCardFromGacha")
end

function DeckController.DrawCardFromGacha(self: DeckController, gachaId: string)
	return self.DrawCardFromGachaRemote(gachaId)
end

return DeckController
