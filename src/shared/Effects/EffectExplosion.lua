local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(args: {
	Position: Vector3,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		return Promise.all({
			EffectController:Effect(EffectEmission({
				Emitter = ReplicatedStorage.Assets.Emitters.ExplosionFlames1,
				Target = args.Position,
				ParticleCount = 16,
			})),
			EffectController:Effect(EffectEmission({
				Emitter = ReplicatedStorage.Assets.Emitters.ExplosionSparks1,
				Target = args.Position,
				ParticleCount = 16,
			})),
			EffectController:Effect(EffectEmission({
				Emitter = ReplicatedStorage.Assets.Emitters.ExplosionShockwave1,
				Target = args.Position,
				ParticleCount = 1,
			})),
		})
	end
end
