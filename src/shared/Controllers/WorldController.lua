local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local WorldController = {
	Priority = 0,
}

type WorldController = typeof(WorldController)

function WorldController.PrepareBlocking(self: WorldController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "WorldService")
	self.WorldsRemote = self.Comm:GetProperty("Worlds")
	self.WorldTeleportRequested = self.Comm:GetSignal("WorldTeleportRequested")
	self.WorldPurchaseRequested = self.Comm:GetSignal("WorldPurchaseRequested")
end

function WorldController.ObserveWorlds(self: WorldController, callback)
	local connection = self.WorldsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return WorldController
