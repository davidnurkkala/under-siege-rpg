local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Health = require(ReplicatedStorage.Shared.Classes.Health)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Battler = {}
Battler.__index = Battler

export type Battler = typeof(setmetatable(
	{} :: {
		Health: Health.Health,
		Position: number,
		Direction: number,
		BaseModel: Model,
		CharModel: Model,
		Destroyed: any,
	},
	Battler
))

function Battler.new(args: {
	HealthMax: number,
	Position: number,
	Direction: number,
	BaseModel: Model,
	CharModel: Model,
}): Battler
	local self: Battler = setmetatable({
		Health = Health.new(args.HealthMax),
		Position = args.Position,
		Direction = args.Direction,
		BaseModel = args.BaseModel,
		CharModel = args.CharModel,
		Destroyed = Signal.new(),
		Changed = Signal.new(),
	}, Battler)

	self.Health:Observe(function()
		self.Changed:Fire(self:GetStatus())
	end)

	return self
end

function Battler.GetStatus(self: Battler)
	return {
		Health = self.Health:Get(),
		HealthMax = self.Health.Max,
	}
end

function Battler.Observe(self: Battler, callback)
	local connection = self.Changed:Connect(callback)
	callback(self:GetStatus())
	return connection
end

function Battler.IsActive(self: Battler)
	return self.Health:Get() > 0
end

function Battler.Destroy(self: Battler)
	self.Destroyed:Fire()
end

return Battler
