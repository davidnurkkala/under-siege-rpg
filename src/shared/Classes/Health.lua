local Health = {}
Health.__index = Health

export type Health = typeof(setmetatable({} :: {
	Amount: number,
	Max: number,
}, Health))

function Health.new(max: number): Health
	local self: Health = setmetatable({
		Amount = max,
		Max = max,
	}, Health)

	return self
end

function Health.Get(self: Health)
	return self.Amount
end

function Health.Set(self: Health, amount: number)
	self.Amount = math.clamp(amount, 0, self.Max)
end

function Health.Adjust(self: Health, delta: number)
	self:Set(self:Get() + delta)
end

function Health.Destroy(self: Health) end

return Health
