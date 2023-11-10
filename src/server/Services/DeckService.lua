local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CardGachaDefs = require(ReplicatedStorage.Shared.Defs.CardGachaDefs)
local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)
local t = require(ReplicatedStorage.Packages.t)

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

	self.Comm:BindFunction("DrawCardFromGacha", function(player, gachaId)
		if not t.string(gachaId) then return end

		return self:DrawCardFromGacha(player, gachaId)
	end)
end

function DeckService.GetDeck(_self: DeckService, player: Player)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("Deck")
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

function DeckService.DrawCardFromGacha(self: DeckService, player: Player, gachaId: string)
	local gacha = CardGachaDefs[gachaId]
	assert(gacha, `No gacha with id {gachaId}`)

	return CurrencyService:ApplyPrice(player, gacha.Price)
		:andThen(function(success)
			if not success then return false, "notEnoughCurrency" end

			return self:AddCard(player, gacha.WeightTable:Roll()):andThenReturn(true)
		end)
		:catch(function()
			return false, "error"
		end)
end

return DeckService
