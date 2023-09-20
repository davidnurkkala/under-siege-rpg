local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectPart = require(ReplicatedStorage.Shared.Util.EffectPart)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

return function(args: {
	Emitter: ParticleEmitter,
	ParticleCount: number,
	Target: BasePart | Attachment | Vector3,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local trove = Trove.new()

		local parent = args.Target
		if typeof(args.Target) == "Vector3" then
			local part = trove:Add(EffectPart())
			part.Size = Vector3.new()
			part.Transparency = 1
			part.Position = args.Target

			parent = Instance.new("Attachment")
			parent.Parent = part

			part.Parent = workspace.Effects
		end

		local emitter = trove:Clone(args.Emitter)
		emitter.Parent = parent
		emitter:Emit(args.ParticleCount)

		return Promise.delay(emitter.Lifetime.Max):andThenCall(trove.Clean, trove)
	end
end
