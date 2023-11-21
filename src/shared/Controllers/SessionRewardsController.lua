local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local SessionRewardsController = {
	Priority = 0,
}

type SessionRewardsController = typeof(SessionRewardsController)

function SessionRewardsController.PrepareBlocking(self: SessionRewardsController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "SessionRewardsService")
	self.StatusRemote = self.Comm:GetProperty("Status")
	self.ClaimRequestedRemote = self.Comm:GetSignal("ClaimRequested")
end

function SessionRewardsController.ObserveStatus(self: SessionRewardsController, callback)
	local connection = self.StatusRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

function SessionRewardsController.Claim(self: SessionRewardsController, index: number)
	self.ClaimRequestedRemote:Fire(index)
end

return SessionRewardsController
