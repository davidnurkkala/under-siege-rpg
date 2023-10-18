local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectPart = require(ReplicatedStorage.Shared.Util.EffectPart)
local Promise = require(ReplicatedStorage.Packages.Promise)
local SoundDefs = require(ReplicatedStorage.Shared.Defs.SoundDefs)
local Trove = require(ReplicatedStorage.Packages.Trove)

return function(args: {
	SoundId: string,
	Target: Instance | Vector3,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local trove = Trove.new()

		local parent
		if typeof(args.Target) == "Vector3" then
			parent = trove:Add(EffectPart())
			parent.Transparency = 1
			parent.Position = args.Target
			parent.Parent = workspace.Effects
		else
			parent = args.Target
		end

		local sound = trove:Clone(SoundDefs[args.SoundId])
		sound.Parent = parent
		sound:Play()

		return Promise.new(function(resolve, _, onCancel)
			while sound.TimeLength == 0 do
				task.wait()
				if onCancel() then return end
			end

			resolve(sound.TimeLength)
		end)
			:timeout(1)
			:andThen(function(duration)
				return Promise.delay(duration)
			end, function() end)
			:finallyCall(trove.Clean, trove)
	end
end
