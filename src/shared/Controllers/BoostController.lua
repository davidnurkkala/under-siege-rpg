local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local BoostController = {
	Priority = 0,
}

type BoostController = typeof(BoostController)

function BoostController.PrepareBlocking(self: BoostController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "BoostService")
	self.BoostsRemote = self.Comm:GetProperty("Boosts")
end

function BoostController.ObserveBoosts(self: BoostController, callback)
	local connection = self.BoostsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return BoostController
