local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DeckService = {
	Priority = 0,
}

type DeckService = typeof(DeckService)

function DeckService.PrepareBlocking(self: DeckService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "DeckService")
	self.DeckRemote = self.Comm:CreateProperty("Deck")

	Observers.observePlayer(function(player)
		return DataService:ObserveKey(player, "Deck", function(deck)
			self.DeckRemote:SetFor(player, deck)
		end)
	end)
end

function DeckService.AddCard(self: DeckService, player: Player, cardId: string)
	assert(CardDefs[cardId], `No card with id {cardId}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Deck", function(oldDeck)
			local level = (oldDeck.Owned[cardId] or 0) + 1
			local owned = Sift.Dictionary.set(oldDeck.Owned, cardId, level)
			return Sift.Dictionary.set(oldDeck, "Owned", owned)
		end)
	end)
end

function DeckService.SetCardEquipped(self: DeckService, player: Player, cardId: string, equipped: boolean)
	assert(CardDefs[cardId], `No card with id {cardId}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Deck", function(oldDeck)
			if not oldDeck.Owned[cardId] then return oldDeck end

			if equipped then
				if oldDeck.Equipped[cardId] then return oldDeck end

				return Sift.Dictionary.set(oldDeck, "Equipped", Sift.Dictionary.set(oldDeck.Equipped, cardId, true))
			else
				if not oldDeck.Equipped[cardId] then return oldDeck end

				return Sift.Dictionary.set(oldDeck, "Equipped", Sift.Dictionary.removeKey(oldDeck.Equipped, cardId))
			end
		end)
	end)
end

return DeckService
