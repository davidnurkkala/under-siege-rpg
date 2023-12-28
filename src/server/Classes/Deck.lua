local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Deck = {}
Deck.__index = Deck

export type Deck = typeof(setmetatable(
	{} :: {
		Cards: { [string]: number },
		DrawPile: { string },
	},
	Deck
))

function Deck.new(cards: { [string]: number }): Deck
	local self = setmetatable({
		Cards = Sift.Dictionary.copy(cards),
		DrawPile = {},
	}, Deck)

	self:Shuffle()

	return self
end

function Deck.Shuffle(self: Deck)
	self.DrawPile = Sift.Array.shuffle(Sift.Dictionary.keys(self.Cards))
end

function Deck.Draw(self: Deck): { Id: string, Count: number }
	if not self.DrawPile[1] then self:Shuffle() end

	local cardId = table.remove(self.DrawPile, 1)
	return { Id = cardId, Count = self.Cards[cardId] }
end

function Deck.Destroy(self: Deck) end

return Deck
