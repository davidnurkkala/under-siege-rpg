local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local SoundDefs = require(ReplicatedStorage.Shared.Defs.SoundDefs)

return function(soundId)
	local sound = SoundDefs[soundId]:Clone()
	sound.Parent = workspace
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
		:finallyCall(sound.Destroy, sound)
end
