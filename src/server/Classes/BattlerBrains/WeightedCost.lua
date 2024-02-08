local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battler = require(ServerScriptService.Server.Classes.Battler)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeightTable = require(ReplicatedStorage.Shared.Classes.WeightTable)

local WeightedCost = {}
WeightedCost.__index = WeightedCost

export type WeightedCost = typeof(setmetatable(
	{} :: {
		Battler: Battler.Battler,
		Trove: any,
	},
	WeightedCost
))

function WeightedCost.new(battler: Battler.Battler): WeightedCost
	local self: WeightedCost = setmetatable({
		Battler = battler,
		Trove = Trove.new(),
	}, WeightedCost)

	local highestCost = 0
	local entries = Sift.Array.map(Sift.Dictionary.keys(self.Battler.Deck), function(cardId)
		local cardDef = CardDefs[cardId]

		local cost = cardDef.Cost + cardDef.Cooldown * 3
		highestCost = math.max(highestCost, cost)

		return { Result = cardId, Weight = cost }
	end)
	entries = Sift.Array.map(entries, function(entry)
		return Sift.Dictionary.update(entry, "Weight", function(oldWeight)
			return highestCost / oldWeight
		end)
	end)
	local weightTable = WeightTable.new(entries)

	local nextCardId = nil

	self.Trove:Add(task.spawn(function()
		while true do
			self.Battler:Attack()

			if nextCardId == nil then nextCardId = weightTable:Roll() end

			local cardDef = CardDefs[nextCardId]
			if self.Battler.Supplies >= cardDef.Cost then
				self.Battler:GetBattle():PlayCard(self.Battler, nextCardId)
				nextCardId = nil
			end

			task.wait(1)
		end
	end))

	return self
end

function WeightedCost.Destroy(self: WeightedCost)
	self.Trove:Clean()
end

return WeightedCost
