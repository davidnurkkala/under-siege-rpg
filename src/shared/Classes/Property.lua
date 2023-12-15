local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local function Compare(a, b)
	return a == b
end

local Property = {}
Property.__index = Property

export type Property = typeof(setmetatable(
	{} :: {
		Value: any,
		Compare: (any, any) -> boolean,
		Changed: any,
		CleanUps: { [any]: boolean },
	},
	Property
))

function Property.new(value: any, compare: ((any, any) -> boolean)?): Property
	local self: Property = setmetatable({
		Value = value,
		Compare = compare or Compare,
		Changed = Signal.new(),
		CleanUps = {},
	}, Property)

	return self
end

function Property.Observe(self: Property, callback: (any) -> () -> ())
	local cleanUp = callback(self:Get())
	if cleanUp then self.CleanUps[cleanUp] = true end

	local connection = self.Changed:Connect(function()
		if cleanUp then
			cleanUp()
			self.CleanUps[cleanUp] = nil
		end

		cleanUp = callback(self:Get())
		if cleanUp then self.CleanUps[cleanUp] = true end
	end)

	return function()
		if cleanUp then
			cleanUp()
			self.CleanUps[cleanUp] = nil
		end

		connection:Disconnect()
	end
end

function Property.Get(self: Property)
	return self.Value
end

function Property.Set(self: Property, value)
	if self.Compare(self:Get(), value) then return end

	self.Value = value
	self.Changed:Fire()
end

function Property.Destroy(self: Property)
	for cleanUp in self.CleanUps do
		cleanUp()
	end
	self.CleanUps = {}
end

return Property
