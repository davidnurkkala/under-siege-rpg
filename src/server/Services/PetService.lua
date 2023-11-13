local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local Observers = require(ReplicatedStorage.Packages.Observers)
local PetGachaDefs = require(ReplicatedStorage.Shared.Defs.PetGachaDefs)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local t = require(ReplicatedStorage.Packages.t)

local PetService = {
	Priority = 0,
}

type PetService = typeof(PetService)

function PetService.PrepareBlocking(self: PetService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "PetService")

	self.PetsRemote = self.Comm:CreateProperty("Pets")
	Observers.observePlayer(function(player)
		return DataService:ObserveKey(player, "Pets", function(pets)
			self.PetsRemote:SetFor(player, pets)
		end)
	end)

	self.Comm:BindFunction("HatchPetFromGacha", function(player, gachaId)
		if not t.string(gachaId) then return end

		return self:HatchPetFromGacha(player, gachaId):expect()
	end)

	self.Comm:BindFunction("ToggleEquipped", function(player, slotId)
		if not t.string(slotId) then return end

		return self:TogglePetEquipped(player, slotId):expect()
	end)
end

function PetService.AddPet(_self: PetService, player: Player, petId: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Pets", function(pets)
			local slotId = Guid()

			return Sift.Dictionary.set(
				pets,
				"Owned",
				Sift.Dictionary.set(pets.Owned, slotId, {
					PetId = petId,
					Id = slotId,
					Tier = 1,
				})
			)
		end)
	end)
end

function PetService.GetMaxPetSlots(_self: PetService, _player: Player)
	return Promise.resolve(3)
end

function PetService.TogglePetEquipped(self: PetService, player: Player, slotId: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local pets = saveFile:Get("Pets")
		if not pets.Owned[slotId] then return end

		local equipped = pets.Equipped[slotId] == true
		return self:SetPetEquipped(player, slotId, not equipped)
	end)
end

function PetService.SetPetEquipped(self: PetService, player: Player, slotId: string, equipped: boolean)
	return Promise.all({
		DataService:GetSaveFile(player),
		self:GetMaxPetSlots(player),
	}):andThen(function(results)
		local saveFile, maxPetSlots = unpack(results)

		saveFile:Update("Pets", function(pets)
			if not pets.Owned[slotId] then return pets end

			if equipped then
				if pets.Equipped[slotId] ~= nil then return pets end
				if #Sift.Dictionary.keys(pets.Equipped) >= maxPetSlots then return pets end

				return Sift.Dictionary.set(pets, "Equipped", Sift.Dictionary.set(pets.Equipped, slotId, true))
			else
				if pets.Equipped[slotId] == nil then return pets end

				return Sift.Dictionary.set(pets, "Equipped", Sift.Dictionary.removeKey(pets.Equipped, slotId))
			end
		end)
	end)
end

function PetService.RemovePet(self: PetService, player: Player, slotId: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Pets", function(pets)
			if not pets.Owned[slotId] then return pets end

			return Sift.Dictionary.merge(pets, {
				Owned = Sift.Dictionary.removeKey(pets.Owned, slotId),
				Equipped = Sift.Dictionary.removeKey(pets.Equipped, slotId),
			})
		end)
	end)
end

function PetService.HatchPetFromGacha(self: PetService, player: Player, gachaId: string)
	local gacha = PetGachaDefs[gachaId]
	assert(gacha, `No gacha with id {gachaId}`)

	return CurrencyService:ApplyPrice(player, gacha.Price)
		:andThen(function(success)
			if not success then return false, "notEnoughCurrency" end

			local petId = gacha.WeightTable:Roll()
			return self:AddPet(player, petId):andThenReturn(true, petId)
		end)
		:catch(function(problem)
			warn(problem)
			return false, "error"
		end)
end

return PetService
