local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EffectGrindPets = require(ReplicatedStorage.Shared.Effects.EffectGrindPets)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local Observers = require(ReplicatedStorage.Packages.Observers)
local PetGachaDefs = require(ReplicatedStorage.Shared.Defs.PetGachaDefs)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Range = require(ReplicatedStorage.Shared.Util.Range)
local Sift = require(ReplicatedStorage.Packages.Sift)
local t = require(ReplicatedStorage.Packages.t)

local Rand = Random.new()

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

	self.Comm:BindFunction("MergePets", function(player, petId, tier, count)
		if not t.string(petId) then return end
		if not t.integer(tier) then return end
		if tier < 1 then return end
		if not t.integer(count) then return end
		if count < 2 then return end
		if count > 4 then return end

		return self:MergePets(player, petId, tier, count):expect()
	end)
end

function PetService.AddPet(_self: PetService, player: Player, petId: string, tier: number?)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Pets", function(pets)
			local slotId = Guid()

			return Sift.Dictionary.set(
				pets,
				"Owned",
				Sift.Dictionary.set(pets.Owned, slotId, {
					PetId = petId,
					Id = slotId,
					Tier = tier or 1,
				})
			)
		end)
	end)
end

function PetService.MergePets(self: PetService, player: Player, petId: string, tier: number, count: number)
	return self:GetPets(player):andThen(function(pets)
		pets = Sift.Dictionary.values(Sift.Dictionary.filter(pets.Owned, function(pet)
			return (pet.PetId == petId) and (pet.Tier == tier)
		end))

		if #pets < count then return false end

		return Promise.all(Sift.Array.map(Range(count), function(index)
			return self:RemovePet(player, pets[index].Id)
		end)):andThen(function()
			local roll = Rand:NextInteger(1, 4) - count
			local success = roll < 1

			EffectService:Effect(
				player,
				EffectGrindPets({
					PetId = petId,
					Success = success,
					Count = count,
				})
			)

			if success then
				return self:AddPet(player, petId, tier + 1):andThenReturn(true)
			else
				return false
			end
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

function PetService.GetPets(_self: PetService, player: Player)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("Pets")
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
