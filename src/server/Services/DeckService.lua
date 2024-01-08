local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CardGachaDefs = require(ReplicatedStorage.Shared.Defs.CardGachaDefs)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local MultiRollHelper = require(ServerScriptService.Server.Util.MultiRollHelper)
local Observers = require(ReplicatedStorage.Packages.Observers)
local OptionsService = require(ServerScriptService.Server.Services.OptionsService)
local Promise = require(ReplicatedStorage.Packages.Promise)
local QuestService = require(ServerScriptService.Server.Services.QuestService)
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

	self.Comm:BindFunction("DrawCardFromGacha", function(player, gachaId, count)
		if not t.string(gachaId) then return end
		if not t.integer(count) then return end
		if count < 1 then return end
		if count > 1000 then return end

		return self:DrawCardFromGacha(player, gachaId, count):catch(warn):expect()
	end)

	self.Comm:CreateSignal("CardEquipToggleRequested"):Connect(function(player, cardId)
		if not t.string(cardId) then return end

		return self:GetDeck(player)
			:andThen(function(deck)
				if not deck.Owned[cardId] then return end

				return self:SetCardEquipped(player, cardId, deck.Equipped[cardId] == nil)
			end)
			:expect()
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
				for cardId, count in cards do
					if owned[cardId] == nil then table.insert(newCards, cardId) end

					owned = Sift.Dictionary.update(owned, cardId, function(oldCount)
						return oldCount + count
					end, function()
						return count
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

function DeckService.AddCard(self: DeckService, player: Player, cardId: string)
	assert(CardDefs[cardId], `No card with id {cardId}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local isNewCard = saveFile:Get("Deck").Owned[cardId] == nil
		local count = 0

		saveFile:Update("Deck", function(oldDeck)
			count = (oldDeck.Owned[cardId] or 0) + 1
			local owned = Sift.Dictionary.set(oldDeck.Owned, cardId, count)
			return Sift.Dictionary.set(oldDeck, "Owned", owned)
		end)

		if not isNewCard then return Promise.resolve(count) end

		return OptionsService:GetOption(player, "AutoEquipCards")
			:andThen(function(autoEquip)
				if not autoEquip then return end

				return self:SetCardEquipped(player, cardId, true)
			end)
			:andThenReturn(count)
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

function DeckService.DrawCardFromGacha(self: DeckService, player: Player, gachaId: string, countBoughtIn: number?)
	local gacha = CardGachaDefs[gachaId]
	assert(gacha, `No gacha with id {gachaId}`)

	local countBought = countBoughtIn or 1

	return Promise.new(function(resolve, _, onCancel)
		local check = MultiRollHelper.Check(player, countBought)
		onCancel(function()
			check:cancel()
		end)

		local canProceed = check:expect()
		if onCancel() then return end
		if not canProceed then
			resolve({})
			return
		end

		if gacha.QuestRequirement then
			local questCheck = QuestService:IsQuestComplete(player, gacha.QuestRequirement)
			onCancel(function()
				questCheck:cancel()
			end)

			local questComplete = questCheck:expect()
			if onCancel() then return end
			if not questComplete then
				resolve({})
				return
			end
		end

		local cards = {}

		for _ = 1, countBought do
			local applyPrice = CurrencyService:ApplyPrice(player, gacha.Price)
			onCancel(function()
				applyPrice:cancel()
			end)

			local hadFunds = applyPrice:expect()
			if onCancel() then return end

			if not hadFunds then
				resolve(cards)
				return
			end

			local cardId = gacha.WeightTable:Roll()
			cards[cardId] = (cards[cardId] or 0) + 1
		end

		resolve(cards)
	end)
		:andThen(function(cards)
			if Sift.Dictionary.count(cards) == 0 then return false, "none" end

			EventStream.Event({ Kind = "CardGachaRolled", Player = player, GachaId = gachaId })

			return self:GetDeck(player)
				:andThen(function(deck)
					return Sift.Dictionary.map(cards, function(_, cardId)
						return (deck.Owned[cardId] or 0), cardId
					end),
						Sift.Dictionary.map(cards, function(count, cardId)
							return (deck.Owned[cardId] or 0) + count, cardId
						end)
				end)
				:andThen(function(oldCounts, newCounts)
					return self:AddCards(player, cards):andThenReturn(
						true,
						Sift.Array.map(Sift.Dictionary.keys(cards), function(cardId)
							local countOld = oldCounts[cardId]
							local countNew = newCounts[cardId]
							local didLevelUp = CardHelper.CountToLevel(countNew) > CardHelper.CountToLevel(countOld)

							return {
								CardId = cardId,
								CountOld = countOld,
								CountNew = countNew,
								DidLevelUp = didLevelUp,
							}
						end)
					)
				end)
		end)
		:catch(function(problem)
			warn(problem)
			return false, "error"
		end)
end

return DeckService
