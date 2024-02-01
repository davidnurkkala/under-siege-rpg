local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local ResourceNodeController = {
	Priority = 0,
}

type ResourceNodeController = typeof(ResourceNodeController)

function ResourceNodeController.PrepareBlocking(self: ResourceNodeController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "ResourceNodeService")
	self.StatesRemote = self.Comm:GetProperty("States")
	self.UseNode = self.Comm:GetFunction("UseNode")
end

function ResourceNodeController.ObserveStates(self: ResourceNodeController, callback)
	local connection = self.StatesRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return ResourceNodeController
