local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
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
	Battle: any,
}): Goon
	local self: Goon = setmetatable({
		Health = Health.new(args.HealthMax),
		Position = args.Position,
		Direction = args.Direction,
		Model = args.Model,
		Size = args.Size,
		TeamId = args.TeamId,
		Battle = args.Battle,
		OnUpdated = args.OnUpdated,
	}, Goon)

	self.Battle:Add(self)

	return self
end

function Goon.fromId(id: string)
	local def = GoonDefs[id]
	assert(def, `No def found for {id}`)

	local model = def.Model:Clone()
end

function Goon.IsActive(self: Goon)
	return self.Health:Get() > 0
end

function Goon.Update(self: Goon, dt: number)
	self:OnUpdated(dt)
end

function Goon.Destroy(self: Goon)
	self.Battle:Remove(self)
end

return Goon
