local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Comm = require(ReplicatedStorage.Packages.Comm)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local MusicDefs = require(ReplicatedStorage.Shared.Defs.MusicDefs)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)

local MusicController = {
	Priority = 0,
}

type MusicController = typeof(MusicController)

function MusicController.PrepareBlocking(self: MusicController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "MusicService")
	self.SoundtrackRemote = self.Comm:GetProperty("Soundtrack")

	self.Soundtrack = Property.new(nil, Sift.Array.equals)

	self.SoundtrackRemote:Observe(function(soundtrack)
		self.Soundtrack:Set(soundtrack)
	end)

	self.Soundtrack:Observe(function(soundtrack)
		if not soundtrack then return end

		local promise = Promise.new(function(_, _, onCancel)
			while true do
				for _, musicId in Sift.Array.shuffle(soundtrack) do
					local sound: Sound = MusicDefs[musicId]:Clone()
					sound.Parent = workspace

					sound.Loaded:Wait()
					if onCancel(function()
						sound:Destroy()
					end) then return end

					sound:Play()

					local goalVolume = sound.Volume
					local fadeIn = Animate(1, function(scalar)
						sound.Volume = Lerp(0, goalVolume, scalar)
					end)

					local songFinish = Promise.race({
						Promise.fromEvent(sound.Ended),
						Promise.fromEvent(sound.DidLoop),
					})

					onCancel(function()
						fadeIn:cancel()
						songFinish:cancel()

						local volume = sound.Volume
						Animate(1, function(scalar)
							sound.Volume = Lerp(volume, 0, scalar)
						end):finally(function()
							sound:Destroy()
						end)
					end)

					songFinish:expect()
					if onCancel() then return end

					sound:Destroy()
				end

				-- failsafe
				task.wait()
				if onCancel() then return end
			end
		end)

		return function()
			promise:cancel()
		end
	end)
end

return MusicController
