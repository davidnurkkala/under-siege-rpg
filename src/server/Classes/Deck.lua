local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Deck = {}
Deck.__index = Deck

export type Deck = typeof(setmetatable(
	{} :: {
		Cards: { [string]: number },
		DiscardPile: { [string]: number },
		DrawPile: { [string]: boolean },
	},
	Deck
))

function Deck.new(cards: { [string]: number }): Deck
	local self = setmetatable({
		Cards = Sift.Dictionary.copy(cards),
		DrawPile = Sift.Array.toSet(Sift.Dictionary.keys(cards)),
		DiscardPile = {},
	}, Deck)

	return self
end

function Deck.Tick(self: Deck)
	for cardId in self.DiscardPile do
		self.DiscardPile[cardId] -= 1
		if self.DiscardPile[cardId] == 0 then
			self.DiscardPile[cardId] = nil
			self.DrawPile[cardId] = true
		end
	end
end

function Deck.Draw(self: Deck, count: number): { { Id: string, Count: number } }
	local cardIds = Sift.Array.shuffle(Sift.Set.toArray(self.DrawPile))
	local choices = {}

	for index = 1, count do
		if cardIds[index] then
			table.insert(choices, { Id = cardIds[index], Count = self.Cards[cardIds[index]] })
		else
			table.insert(choices, { Id = "Nothing", Count = 1 })
		end
	end

	return choices
end

function Deck.Use(self: Deck, choice)
	if self.DrawPile[choice.Id] == nil then return choice end
	if self.DiscardPile[choice.Id] ~= nil then return choice end

	if choice.Id == "Nothing" then return choice end

	self.DrawPile[choice.Id] = nil
	self.DiscardPile[choice.Id] = CardDefs[choice.Id].Cooldown

	return choice
end

function Deck.Destroy(self: Deck) end

return Deck
