local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectShakeModel = require(ReplicatedStorage.Shared.Effects.EffectShakeModel)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)

local TrainingDummy = {}
TrainingDummy.__index = TrainingDummy

export type TrainingDummy = typeof(setmetatable({} :: {}, TrainingDummy))

function TrainingDummy.new(model: Model): TrainingDummy
	local self: TrainingDummy = setmetatable({
		Model = model,
		Root = model.PrimaryPart,
	}, TrainingDummy)

	return self
end

function TrainingDummy:GetPosition()
	return self.Root.Core.WorldPosition
end

function TrainingDummy.HitEffect(self: TrainingDummy, hitSoundId: string)
	EffectService:All(
		EffectEmission({
			Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
			ParticleCount = 2,
			Target = self:GetPosition(),
		}),
		EffectSound({
			SoundId = hitSoundId,
			Target = self.Root,
		}),
		EffectShakeModel({
			Model = self.Model,
		})
	)
end

function TrainingDummy.Destroy(self: TrainingDummy) end

return TrainingDummy
