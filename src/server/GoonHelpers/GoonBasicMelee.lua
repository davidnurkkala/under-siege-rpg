local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)

return function(def)
	return Sift.Dictionary.merge(def, {
		GetOnUpdated = function()
			local function walk(self, dt)
				return self.Battle:MoveFieldable(self, self.Direction * self:FromDef("Speed") * dt)
			end

			local function getTarget(self)
				return self.Battle:TargetNearest({
					Position = self.Position,
					Range = self:FromDef("Range"),
					Filter = self.Battle:DefaultFilter(self.TeamId),
				})
			end

			local attackCooldown
			local function getAttackCooldown(self)
				if not attackCooldown then attackCooldown = Cooldown.new(1 / self:FromDef("AttackRate")) end
				return attackCooldown
			end

			return StateMachine({
				{
					Name = "Walking",
					Start = function(self)
						self.Animator:Play(self.Def.Animations.Walk)
					end,
					Run = function(self, _, dt)
						if not walk(self, dt) then return "Waiting" end

						if getTarget(self) then return "Attacking" end

						return
					end,
					Finish = function(self)
						self.Animator:StopHard(self.Def.Animations.Walk)
					end,
				},
				{
					Name = "Waiting",
					Run = function(self, _, dt)
						if walk(self, dt) then return "Walking" end

						return
					end,
				},
				{
					Name = "Attacking",
					Run = function(self, data)
						local target = getTarget(self)

						if target then
							local cooldown = getAttackCooldown(self)

							if cooldown:IsReady() then
								cooldown:Use()

								self.Animator:Play(self.Def.Animations.Attack)

								data.Promise = self:WhileAlive(Promise.delay(1):andThen(function()
									target.Health:Adjust(-self:FromDef("Damage"))

									EffectService:All(
										EffectSound({
											SoundId = PickRandom(self.Def.Sounds.Hit),
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
					Finish = function(self, data)
						self.Animator:StopHard(self.Def.Animations.Attack)

						if data.Promise then data.Promise:cancel() end
					end,
				},
			})
		end,
	})
end
