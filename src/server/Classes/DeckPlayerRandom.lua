local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Range = require(ReplicatedStorage.Shared.Util.Range)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DeckPlayerRandom = {}
DeckPlayerRandom.__index = DeckPlayerRandom

export type DeckPlayerRandom = typeof(setmetatable({} :: {
	Deck: any,
}, DeckPlayerRandom))

function DeckPlayerRandom.new(deck: any): DeckPlayerRandom
	local self: DeckPlayerRandom = setmetatable({
		Deck = deck,
	}, DeckPlayerRandom)

	return self
end

function DeckPlayerRandom.ChooseCard(self: DeckPlayerRandom)
	return Promise.resolve(Sift.Array.first(Sift.Array.shuffle(Sift.Array.map(Range(3), function()
		return self.Deck:Draw()
	end))))
end

function DeckPlayerRandom.Destroy(self: DeckPlayerRandom) end

return DeckPlayerRandom
