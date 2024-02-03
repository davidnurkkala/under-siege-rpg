local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Promise = require(ReplicatedStorage.Packages.Promise)
local CutsceneService = {
	Priority = 0,
}

type CutsceneService = typeof(CutsceneService)

function CutsceneService.PrepareBlocking(self: CutsceneService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "CutsceneService")
	self.CutsceneUpdated = self.Comm:CreateSignal("CutsceneUpdated")
	self.CutsceneFinished = self.Comm:CreateSignal("CutsceneFinished")
end

function CutsceneService.Begin(self: CutsceneService, player: Player)
	self:Step(player)
end

function CutsceneService.Step(self: CutsceneService, player: Player)
	self.CutsceneUpdated:Fire(player)
end

function CutsceneService.OnFinish(self: CutsceneService, player: Player)
	return Promise.fromEvent(self.CutsceneFinished, function(finishingPlayer)
		return finishingPlayer == player
	end)
end

return CutsceneService
