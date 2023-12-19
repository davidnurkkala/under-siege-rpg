local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local PrestigeController = {
	Priority = 0,
}

type PrestigeController = typeof(PrestigeController)

function PrestigeController.PrepareBlocking(self: PrestigeController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "PrestigeService")
	self.PointsRemote = self.Comm:GetProperty("Points")
	self.PrestigeRemote = self.Comm:GetFunction("Prestige")
end

function PrestigeController.ObservePoints(self: PrestigeController, callback)
	local connection = self.PointsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return PrestigeController
