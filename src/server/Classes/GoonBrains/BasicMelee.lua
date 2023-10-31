local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectGoonModel = require(ReplicatedStorage.Shared.Effects.EffectGoonModel)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local Promise = require(ReplicatedStorage.Packages.Promise)
local StateMachine = require(ServerScriptService.Server.Classes.StateMachine)

local BasicMelee = {}
BasicMelee.__index = BasicMelee

export type BasicMelee = typeof(setmetatable({} :: {
	Goon: any,
	Battle: any,
	StateMachine: any,
	AttackCooldown: any,
}, BasicMelee))

function BasicMelee.new(): BasicMelee
	local self: BasicMelee = setmetatable({}, BasicMelee)

	return self
end

function BasicMelee.SetUpStateMachine(self: BasicMelee)
	self.StateMachine = StateMachine.new({
		{
			Name = "Walking",
			Start = function()
				self.Goon.Animator:Play(self.Goon.Def.Animations.Walk)
			end,
			Run = function(_, dt)
				if not self:Walk(dt) then return "Waiting" end

				if self:GetTarget() then return "Attacking" end

				return
			end,
			Finish = function()
				self.Goon.Animator:StopHard(self.Goon.Def.Animations.Walk)
			end,
		},
		{
			Name = "Waiting",
			Run = function(_, dt)
				if self:Walk(dt) then return "Walking" end

				return
			end,
		},
		{
			Name = "Attacking",
			Run = function(data)
				local target = self:GetTarget()

				if target then
					if self.AttackCooldown:IsReady() then
						self.AttackCooldown:Use()

						self.Goon.Animator:Play(self.Goon.Def.Animations.Attack)

						data.Promise = self.Goon:WhileAlive(Promise.delay(1):andThen(function()
							target.Health:Adjust(-self.Goon:FromDef("Damage"))

							EffectService:All(
								EffectSound({
									SoundId = PickRandom(self.Goon.Def.Sounds.Hit),
									Target = target:GetRoot(),
								}),
								EffectEmission({
									Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
									ParticleCount = 2,
									Target = target:GetRoot(),
								})
							)
						end))
					end
				else
					return "Walking"
				end

				return
			end,
			Finish = function(data)
				self.Goon.Animator:StopHard(self.Goon.Def.Animations.Attack)

				if data.Promise then data.Promise:cancel() end
			end,
		},
	})
end

function BasicMelee.SetGoon(self: BasicMelee, goon: any)
	self.Goon = goon
	self.Battle = goon.Battle
	self.AttackCooldown = Cooldown.new(1 / self.Goon:FromDef("AttackRate"))
	self:SetUpStateMachine()
end

function BasicMelee.Update(self: BasicMelee, dt: number)
	self.StateMachine:Update(dt)
end

function BasicMelee.OnDied(self: BasicMelee)
	self.Goon.Animator:StopHardAll()
	self.Goon.Animator:Play(self.Goon.Def.Animations.Die)
	return Promise.all({
		EffectService:All(
			EffectSound({
				SoundId = PickRandom(self.Goon.Def.Sounds.Death),
				Target = self.Goon:GetRoot(),
			}),
			EffectGoonModel({
				Root = self.Goon.Root,
				Name = "EffectFadeModel",
				Args = { FadeTime = 2 },
			})
		),
		Promise.delay(2),
	})
end

function BasicMelee.OnInjured(self: BasicMelee)
	EffectService:All(
		EffectGoonModel({
			Root = self.Goon.Root,
			Name = "EffectColorFadeModel",
			Args = {
				Color = Color3.new(1, 0, 0),
				Duration = 0.5,
			},
		}),
		EffectGoonModel({
			Root = self.Goon.Root,
			Name = "EffectJitterModel",
			Args = {
				Model = self.Model,
				Intensity = 0.5,
				Duration = 0.5,
			},
		})
	)
end

function BasicMelee.GetTarget(self: BasicMelee)
	return self.Battle:TargetNearest({
		Position = self.Goon.Position,
		Range = self.Goon:FromDef("Range"),
		Filter = self.Battle:DefaultFilter(self.Goon.TeamId),
	})
end

function BasicMelee.Walk(self: BasicMelee, dt: number)
	return self.Battle:MoveFieldable(self.Goon, self.Goon.Direction * self.Goon:FromDef("Speed") * dt)
end

function BasicMelee.Destroy(self: BasicMelee)
	self.StateMachine:Destroy()
end

return BasicMelee
