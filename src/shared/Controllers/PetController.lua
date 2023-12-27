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
	self.MergePetsRemote = self.Comm:GetFunction("MergePets")
	self.EquipBestRemote = self.Comm:GetFunction("EquipBest")
	self.EquipPetRemote = self.Comm:GetFunction("EquipPet")
	self.UnequipPetRemote = self.Comm:GetFunction("UnequipPet")
end

function PetController.ObservePets(self: PetController, callback)
	local connection = self.PetsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

function PetController.HatchPetFromGacha(self: PetController, gachaId: string, count: number)
	return self.HatchPetFromGachaRemote(gachaId, count)
end

return PetController
