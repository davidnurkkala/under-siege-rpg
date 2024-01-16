local NaiveOrder = {}
NaiveOrder.__index = NaiveOrder

type Order = { { CardId: string, Count: number } }

export type NaiveOrder = typeof(setmetatable(
	{} :: {
		Order: Order,
		Index: number,
		Remaining: number,
	},
	NaiveOrder
))

function NaiveOrder.new(args: {
	Order: Order,
}): NaiveOrder
	local self: NaiveOrder = setmetatable({
		Order = args.Order,
		Index = 0,
		Remaining = 0,
	}, NaiveOrder)

	self:SetIndex(1)

	return self
end

function NaiveOrder.SetIndex(self: NaiveOrder, index: number)
	self.Index = index
	self.Remaining = self.Order[index].Count
end

function NaiveOrder.Destroy(self: NaiveOrder) end

return NaiveOrder
