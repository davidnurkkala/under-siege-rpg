local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local MusicService = {
	Priority = 0,
}

type MusicService = typeof(MusicService)

function MusicService.PrepareBlocking(self: MusicService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "MusicService")
	self.SoundtrackRemote = self.Comm:CreateProperty("Soundtrack", nil)
end

function MusicService.SetSoundtrack(self: MusicService, player: Player, soundtrack: any)
	self.SoundtrackRemote:SetFor(player, soundtrack)
end

return MusicService
