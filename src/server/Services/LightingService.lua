local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local LightingService = {
	Priority = 0,
}

type LightingService = typeof(LightingService)

function LightingService.PrepareBlocking(self: LightingService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "LightingService")
	self.LightingChangeRequested = self.Comm:CreateSignal("LightingChangeRequested")
end

return LightingService
