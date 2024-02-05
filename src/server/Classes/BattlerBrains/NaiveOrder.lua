local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battler = require(ServerScriptService.Server.Classes.Battler)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local NaiveOrder = {}
NaiveOrder.__index = NaiveOrder

type Order = { { CardId: string, Count: number } }

export type NaiveOrder = typeof(setmetatable(
	{} :: {
		Battler: Battler.Battler,
		Order: Order,
		Index: number,
		Remaining: number,
		Trove: any,
	},
	NaiveOrder
))

function NaiveOrder.new(
	battler: Battler.Battler,
	args: {
		Order: Order,
	}
): NaiveOrder
	local self: NaiveOrder = setmetatable({
		Battler = battler,
		Order = args.Order,
		Index = 0,
		Remaining = 0,
		Trove = Trove.new(),
	}, NaiveOrder)

	self:SetIndex(1)

	self.Trove:Add(task.spawn(function()
		while true do
			self.Battler:Attack()

			local entry = self.Order[self.Index]
			local cardId = entry.CardId
			local cardDef = CardDefs[cardId]
			local hasSupplies = self.Battler.Supplies >= cardDef.Cost
			local offCooldown = self.Battler.DeckCooldowns[cardId]:IsReady()
			if hasSupplies and offCooldown then
				self.Battler:GetBattle():PlayCard(self.Battler, cardId)
				self.Remaining -= 1
				if self.Remaining == 0 then
					local nextIndex = self.Index + 1
					if nextIndex > #self.Order then nextIndex = 1 end
					self:SetIndex(nextIndex)
				end
			end

			task.wait(1)
		end
	end))

	return self
end

function NaiveOrder.SetIndex(self: NaiveOrder, index: number)
	self.Index = index
	self.Remaining = self.Order[index].Count
end

function NaiveOrder.Destroy(self: NaiveOrder)
	self.Trove:Clean()
end

return NaiveOrder
