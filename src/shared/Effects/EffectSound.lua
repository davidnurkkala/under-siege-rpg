local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectPart = require(ReplicatedStorage.Shared.Util.EffectPart)
local Promise = require(ReplicatedStorage.Packages.Promise)
local SoundDefs = require(ReplicatedStorage.Shared.Defs.SoundDefs)
local Trove = require(ReplicatedStorage.Packages.Trove)

return function(args: {
	SoundId: string,
	Parent: Instance?,
	Position: Vector3?,
})
	assert(args.Parent ~= nil or args.Position ~= nil, "Must at least have Parent or Position")

	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local trove = Trove.new()

		local parent = args.Parent
		if args.Position then
			parent = trove:Add(EffectPart())
			parent.Transparency = 1
			parent.Position = args.Position
			parent.Parent = workspace.Effects
		end

		local sound = trove:Clone(SoundDefs[args.SoundId])
		sound.Parent = parent
		sound:Play()

		return Promise.delay(sound.TimeLength) --:andThenCall(trove.Clean, trove)
	end
end
