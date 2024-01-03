local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Range = require(ReplicatedStorage.Shared.Util.Range)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DeckPlayerRandom = {}
DeckPlayerRandom.__index = DeckPlayerRandom

export type DeckPlayerRandom = typeof(setmetatable(
	{} :: {
		Deck: any,
	},
	DeckPlayerRandom
))

function DeckPlayerRandom.new(deck: any): DeckPlayerRandom
	local self: DeckPlayerRandom = setmetatable({
		Deck = deck,
	}, DeckPlayerRandom)

	return self
end

function DeckPlayerRandom.ChooseCard(self: DeckPlayerRandom)
	self.Deck:Tick()

	local choices = self.Deck:Draw(3)

	return Promise.try(function()
		for _, choice in choices do
			if choice.Id ~= "Nothing" then return choice end
		end

		return choices[1]
	end):andThen(function(choice)
		return self.Deck:Use(choice)
	end)
end

function DeckPlayerRandom.Destroy(self: DeckPlayerRandom) end

return DeckPlayerRandom
