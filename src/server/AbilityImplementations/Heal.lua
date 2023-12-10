local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectGodRay = require(ReplicatedStorage.Shared.Effects.EffectGodRay)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(self, level, battler, battle)
	local target = battle:TargetFurthest({
		Position = battler.Position,
		Filter = battle:AllyFilter(battler.TeamId),
	})

	if not target then return end

	Promise.try(function()
		EffectService:All(
			EffectEmission({
				Emitter = ReplicatedStorage.Assets.Emitters.Heal1,
				ParticleCount = 1,
				Target = target:GetRoot(),
			}),
			EffectGodRay({
				Target = target:GetRoot(),
				Beam = ReplicatedStorage.Assets.Beams.HealGodRay1,
				Length = 32,
				Width = 8,
				Duration = 1,
			}),
			EffectSound({
				Target = target:GetRoot(),
				SoundId = "Heal1",
			})
		)
	end):catch(function() end)

	target.Health:Adjust(self.Amount(level))
end
