local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local EffectColorFadeModel = require(ReplicatedStorage.Shared.Effects.EffectColorFadeModel)
local EffectFadeModel = require(ReplicatedStorage.Shared.Effects.EffectFadeModel)
local EffectJitterModel = require(ReplicatedStorage.Shared.Effects.EffectJitterModel)
local EffectMoveModel = require(ReplicatedStorage.Shared.Effects.EffectMoveModel)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Health = require(ReplicatedStorage.Shared.Classes.Health)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)

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
		Battle: any,
		Def: any,
		Animator: any,
		Destroyed: any,
		Level: number,
	},
	Goon
))

function Goon.new(args: {
	Position: number,
	Direction: number,
	TeamId: string,
	Model: Model,
	Def: any,
	Level: number,
	OnUpdated: (Goon, number) -> (),
	Battle: any,
}): Goon
	local self: Goon = setmetatable({
		Level = args.Level,
		Health = Health.new(args.Def.HealthMax(args.Level)),
		Position = args.Position,
		Direction = args.Direction,
		Model = args.Model,
		Size = args.Def.Size,
		TeamId = args.TeamId,
		Battle = args.Battle,
		Def = args.Def,
		OnUpdated = args.OnUpdated,
		Destroyed = Signal.new(),
	}, Goon)

	self.Model.Parent = workspace
	self.Animator = Animator.new(self.Model:FindFirstChildWhichIsA("AnimationController") :: AnimationController)

	self.Health:Observe(function(old, new)
		local change = new - old
		if change <= -5 then self:InjuryEffect() end
	end)

	self.Battle:Add(self)

	return self
end

function Goon.fromId(args: {
	Id: string,
	Position: number,
	Direction: number,
	TeamId: string,
	Battle: any,
	Level: number,
})
	local def = GoonDefs[args.Id]
	assert(def, `No def found for {args.Id}`)

	return Goon.new(Sift.Dictionary.merge(args, {
		Model = def.Model:Clone(),
		OnUpdated = def.GetOnUpdated(),
		Def = def,
	}))
end

function Goon.FromDef(self: Goon, key: string)
	return self.Def[key](self.Level)
end

function Goon.IsActive(self: Goon)
	return self.Health:Get() > 0
end

function Goon.InjuryEffect(self: Goon)
	EffectService:All(
		EffectColorFadeModel({
			Model = self.Model,
			Color = Color3.new(1, 0, 0),
			Duration = 0.5,
		}),
		EffectJitterModel({
			Model = self.Model,
			Intensity = 0.5,
			Duration = 0.5,
		})
	)
end

function Goon.Update(self: Goon, dt: number)
	self:OnUpdated(dt)

	local position = self.Battle.Path:ToWorld(self.Position)
	if not self.Model:GetPivot().Position:FuzzyEq(position, 0.0001) then
		EffectService:All(EffectMoveModel({
			Model = self.Model,
			CFrame = CFrame.fromMatrix(position, if self.Direction < 0 then Vector3.zAxis else -Vector3.zAxis, Vector3.yAxis),
		}))
	end
end

function Goon.GetRoot(self: Goon): BasePart
	assert(self.Model.PrimaryPart, `No primary part`)
	return self.Model.PrimaryPart
end

function Goon.GetWorldCFrame(self: Goon)
	return self:GetRoot().CFrame
end

function Goon.WhileAlive(self: Goon, promise)
	return Promise.race({
		Promise.fromEvent(self.Destroyed),
		promise,
	})
end

function Goon.Destroy(self: Goon)
	self.Battle:Remove(self)

	if self.Health:Get() > 0 then
		self.Model:Destroy()
	else
		self.Animator:StopHardAll()
		self.Animator:Play(self.Def.Animations.Die)
		EffectService:All(
			EffectSound({
				SoundId = PickRandom(self.Def.Sounds.Death),
				Target = self:GetRoot(),
			}),
			EffectFadeModel({
				Model = self.Model,
				FadeTime = 2,
			})
		):andThenCall(self.Model.Destroy, self.Model)
	end

	self.Destroyed:Fire()
end

return Goon
