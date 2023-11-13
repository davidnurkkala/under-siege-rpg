local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local PetController = {
	Priority = 0,
}

type PetController = typeof(PetController)

function PetController.PrepareBlocking(self: PetController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "PetService")
	self.PetsRemote = self.Comm:GetProperty("Pets")
	self.HatchPetFromGachaRemote = self.Comm:GetFunction("HatchPetFromGacha")
	self.ToggleEquippedRemote = self.Comm:GetFunction("ToggleEquipped")
end

function PetController.ToggleEquipped(self: PetController, slotId: string)
	return self.ToggleEquippedRemote(slotId)
end

function PetController.ObservePets(self: PetController, callback)
	local connection = self.PetsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

function PetController.HatchPetFromGacha(self: PetController, gachaId: string)
	return self.HatchPetFromGachaRemote(gachaId)
end

return PetController
