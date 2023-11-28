local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectGoonModel = require(ReplicatedStorage.Shared.Effects.EffectGoonModel)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local Promise = require(ReplicatedStorage.Packages.Promise)
local StateMachine = require(ServerScriptService.Server.Classes.StateMachine)

local BasicRanged = {}
BasicRanged.__index = BasicRanged

export type BasicRanged = typeof(setmetatable(
	{} :: {
		Goon: any,
		Battle: any,
		StateMachine: any,
		AttackCooldown: any,
		ProjectileOffset: CFrame,
	},
	BasicRanged
))

function BasicRanged.new(args: {
	ProjectileOffset: CFrame,
}): BasicRanged
	local self: BasicRanged = setmetatable({
		ProjectileOffset = args.ProjectileOffset,
	}, BasicRanged)

	return self
end

function BasicRanged.SetUpStateMachine(self: BasicRanged)
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
			Run = function(data, dt)
				local target = self:GetTarget()

				if target then
					local distance = math.abs(target.Position - self.Goon.Position)
					local isPastHalfRange = distance > self.Goon:FromDef("Range") * 0.5
					local currentlyAttacking = data.Attacking == true
					local shouldWalk = isPastHalfRange and not currentlyAttacking
					if shouldWalk then
						self:Walk(dt)
						self.Goon.Animator:Play(self.Goon.Def.Animations.Walk)
					else
						self.Goon.Animator:Stop(self.Goon.Def.Animations.Walk)
					end

					if self.AttackCooldown:IsReady() then
						self.AttackCooldown:Use()

						self.Goon.Animator:Play(self.Goon.Def.Animations.Attack)

						data.Attacking = true
						data.Promise = self.Goon:WhileAlive(Promise.delay(self.Goon:FromDef("AttackWindupTime") or 1)
							:andThen(function()
								EffectService:All(
									EffectProjectile({
										Model = ReplicatedStorage.Assets.Models.Arrow1,
										Start = self.Goon.Root.CFrame * self.ProjectileOffset,
										Finish = target:GetRoot(),
										Speed = 128,
									}),
									EffectSound({
										SoundId = PickRandom(self.Goon.Def.Sounds.Shoot),
										Target = self.Goon.Root,
									})
								):andThen(function()
									self.Battle:Damage(self.Goon, target, self.Goon:FromDef("Damage"))

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
								end, function()
									-- catch
								end)
							end)
							:finally(function()
								data.Attacking = nil
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

function BasicRanged.SetGoon(self: BasicRanged, goon: any)
	self.Goon = goon
	self.Battle = goon.Battle
	self.AttackCooldown = Cooldown.new(1 / self.Goon:FromDef("AttackRate"))
	self:SetUpStateMachine()
end

function BasicRanged.Update(self: BasicRanged, dt: number)
	self.StateMachine:Update(dt)
end

function BasicRanged.OnDied(self: BasicRanged)
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

function BasicRanged.OnInjured(self: BasicRanged)
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

function BasicRanged.GetTarget(self: BasicRanged)
	return self.Battle:TargetNearest({
		Position = self.Goon.Position,
		Range = self.Goon:FromDef("Range"),
		Filter = self.Battle:DefaultFilter(self.Goon.TeamId),
	})
end

function BasicRanged.Walk(self: BasicRanged, dt: number)
	return self.Battle:MoveFieldable(self.Goon, self.Goon.Direction * self.Goon:FromDef("Speed") * dt)
end

function BasicRanged.Destroy(self: BasicRanged)
	self.StateMachine:Destroy()
end

return BasicRanged
