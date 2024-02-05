local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local Comm = require(ReplicatedStorage.Packages.Comm)
local Configuration = require(ReplicatedStorage.Shared.Configuration)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local OptionsService = require(ServerScriptService.Server.Services.OptionsService)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)

local DeckService = {
	Priority = 0,
	CardUpgraded = Signal.new(),
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

	self.Comm:CreateSignal("CardEquipToggleRequested"):Connect(function(player, cardId)
		if not t.string(cardId) then return end

		self:GetDeck(player):andThen(function(deck)
			if not deck.Owned[cardId] then return end

			return self:SetCardEquipped(player, cardId, deck.Equipped[cardId] == nil)
		end)
	end)

	self.Comm:BindFunction("UpgradeCard", function(player, cardId)
		if not t.string(cardId) then return end

		return self:UpgradeCard(player, cardId):expect()
	end)
end

function DeckService.GetDeck(_self: DeckService, player: Player)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("Deck")
	end)
end

function DeckService.GetDeckForBattle(self: DeckService, player: Player)
	return self:GetDeck(player):andThen(function(deck)
		return Sift.Dictionary.map(deck.Equipped, function(_, cardId)
			return deck.Owned[cardId], cardId
		end)
	end)
end

function DeckService.AddCards(self: DeckService, player: Player, cards: { [string]: number })
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local newCards = {}

		saveFile:Update("Deck", function(deck)
			return Sift.Dictionary.update(deck, "Owned", function(owned)
				for cardId, level in cards do
					if owned[cardId] == nil then table.insert(newCards, cardId) end

					owned = Sift.Dictionary.update(owned, cardId, function(oldLevel)
						return oldLevel + level
					end, function()
						return level
					end)
				end

				return owned
			end)
		end)

		if #newCards == 0 then return true end

		return OptionsService:GetOption(player, "AutoEquipCards"):andThen(function(autoEquip)
			if not autoEquip then return end

			saveFile:Update("Deck", function(deck)
				return Sift.Dictionary.update(deck, "Equipped", function(equipped)
					for _, cardId in newCards do
						equipped = Sift.Set.add(equipped, cardId)
					end

					return equipped
				end)
			end)

			return true
		end)
	end)
end

function DeckService.HasCard(self: DeckService, player: Player, cardId: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("Deck").Owned[cardId] ~= nil
	end)
end

function DeckService.UpgradeCard(self: DeckService, player: Player, cardId: string)
	return DataService:GetSaveFile(player)
		:andThen(function(saveFile)
			local deck = saveFile:Get("Deck")

			local level = deck.Owned[cardId]
			if not level then return false end
			local upgrade = CardHelper.GetUpgrade(cardId, level)
			if upgrade == nil then return false end

			return CurrencyService:ApplyPrice(player, upgrade):andThen(function(success)
				if not success then return false end

				saveFile:Update("Deck", function(oldDeck)
					return Sift.Dictionary.update(oldDeck, "Owned", function(oldOwned)
						return Sift.Dictionary.update(oldOwned, cardId, function(oldLevel)
							return oldLevel + 1
						end)
					end)
				end)

				self.CardUpgraded:Fire(player, cardId)

				return true
			end)
		end)
		:catch(function()
			return false
		end)
end

function DeckService.AddCard(self: DeckService, player: Player, cardId: string)
	assert(CardDefs[cardId], `No card with id {cardId}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local isNewCard = saveFile:Get("Deck").Owned[cardId] == nil
		local level = 0

		saveFile:Update("Deck", function(oldDeck)
			level = (oldDeck.Owned[cardId] or 0) + 1
			local owned = Sift.Dictionary.set(oldDeck.Owned, cardId, level)
			return Sift.Dictionary.set(oldDeck, "Owned", owned)
		end)

		if not isNewCard then return Promise.resolve(level) end

		return OptionsService:GetOption(player, "AutoEquipCards")
			:andThen(function(autoEquip)
				if not autoEquip then return end

				return self:SetCardEquipped(player, cardId, true)
			end)
			:andThenReturn(level)
	end)
end

function DeckService.SetCardEquipped(self: DeckService, player: Player, cardId: string, equipped: boolean)
	assert(CardDefs[cardId], `No card with id {cardId}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Deck", function(oldDeck)
			if not oldDeck.Owned[cardId] then return oldDeck end

			if equipped then
				if oldDeck.Equipped[cardId] then return oldDeck end
				if Sift.Set.count(oldDeck.Equipped) >= Configuration.DeckSizeMax then return oldDeck end

				return Sift.Dictionary.set(oldDeck, "Equipped", Sift.Dictionary.set(oldDeck.Equipped, cardId, true))
			else
				if not oldDeck.Equipped[cardId] then return oldDeck end

				return Sift.Dictionary.set(oldDeck, "Equipped", Sift.Dictionary.removeKey(oldDeck.Equipped, cardId))
			end
		end)
	end)
end

return DeckService
