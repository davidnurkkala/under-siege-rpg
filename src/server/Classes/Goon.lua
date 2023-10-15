local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Health = require(ReplicatedStorage.Shared.Classes.Health)

local Goon = {}
Goon.__index = Goon

export type Goon = typeof(setmetatable(
	{} :: {
		Position: number,
		Size: number,
		TeamId: string,
		Direction: number,
		Model: Model,
		Health: Health.Health,
		OnUpdated: (Goon, number) -> (),
	},
	Goon
))

function Goon.new(args: {
	Position: number,
	Direction: number,
	Size: number,
	TeamId: string,
	Model: Model,
	HealthMax: number,
	OnUpdated: (Goon, number) -> (),
}): Goon
	local self: Goon = setmetatable({
		Health = Health.new(args.HealthMax),
		Position = args.Position,
		Direction = args.Direction,
		Model = args.Model,
		Size = args.Size,
		TeamId = args.TeamId,
		OnUpdated = args.OnUpdated,
	}, Goon)

	return self
end

function Goon.IsActive(self: Goon)
	return self.Health:Get() > 0
end

function Goon.Update(self: Goon, dt: number)
	self:OnUpdated(dt)
end

function Goon.Destroy(self: Goon) end

return Goon
