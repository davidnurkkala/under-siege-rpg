local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DeckController = {
	Priority = 0,
}

type DeckController = typeof(DeckController)

function DeckController.PrepareBlocking(self: DeckController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "DeckService")
	self.DeckRemote = self.Comm:GetProperty("Deck")
	self.CardEquipToggleRequested = self.Comm:GetSignal("CardEquipToggleRequested")
end

function DeckController.ObserveDeck(self: DeckController, callback)
	local connection = self.DeckRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return DeckController
