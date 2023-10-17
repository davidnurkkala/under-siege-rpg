local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
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
		Changed = Signal.new(),
	}, Health)

	return self
end

function Health.Observe(self: Health, callback)
	local connection = self.Changed:Connect(callback)
	callback()
	return connection
end

function Health.Get(self: Health)
	return self.Amount
end

function Health.Set(self: Health, amount: number)
	if amount == self.Amount then return end

	self.Amount = math.clamp(amount, 0, self.Max)
	self.Changed:Fire()
end

function Health.Adjust(self: Health, delta: number)
	self:Set(self:Get() + delta)
end

function Health.Destroy(self: Health) end

return Health
