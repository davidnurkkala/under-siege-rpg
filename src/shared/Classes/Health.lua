local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Health = {}
Health.__index = Health

export type Health = typeof(setmetatable(
	{} :: {
		Amount: number,
		Max: number,
	},
	Health
))

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
	callback(self.Amount, self.Amount)
	return function()
		connection:Disconnect()
	end
end

function Health.GetPercent(self: Health)
	return self:Get() / self:GetMax()
end

function Health.GetMax(self: Health)
	return self.Max
end

function Health.Get(self: Health)
	return self.Amount
end

function Health.Set(self: Health, amount: number)
	if amount == self.Amount then return end

	local oldAmount = self.Amount

	self.Amount = math.clamp(amount, 0, self.Max)
	self.Changed:Fire(oldAmount, self.Amount)
end

function Health.SetMax(self: Health, amount: number)
	if amount == self.Max then return end

	self.Max = amount

	local oldAmount = self.Amount
	if self.Amount > self.Max then self.Amount = self.Max end

	self.Changed:Fire(oldAmount, self.Amount)
end

function Health.Adjust(self: Health, delta: number)
	self:Set(self:Get() + delta)
end

function Health.Reset(self: Health)
	self:Set(self:GetMax())
end

function Health.Destroy(self: Health) end

return Health
