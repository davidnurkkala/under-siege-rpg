local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CosmeticController = {
	Priority = 0,
}

type CosmeticController = typeof(CosmeticController)

function CosmeticController.PrepareBlocking(self: CosmeticController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "CosmeticService")
	self.CosmeticsRemote = self.Comm:GetProperty("Cosmetics")
	self.EquipCosmetic = self.Comm:GetFunction("Equip")
end

function CosmeticController.ObserveCosmetics(self: CosmeticController, callback)
	local connection = self.CosmeticsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return CosmeticController
