local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EffectGrindPets = require(ReplicatedStorage.Shared.Effects.EffectGrindPets)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local Observers = require(ReplicatedStorage.Packages.Observers)
local OptionsService = require(ServerScriptService.Server.Services.OptionsService)
local PetGachaDefs = require(ReplicatedStorage.Shared.Defs.PetGachaDefs)
local PetHelper = require(ReplicatedStorage.Shared.Util.PetHelper)
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

	self.Comm:BindFunction("MergePets", function(player, hash, count)
		if not t.string(hash) then return end
		if not t.integer(count) then return end
		if count < 2 then return end
		if count > 4 then return end

		return self:MergePets(player, hash, count):expect()
	end)

	self.Comm:BindFunction("EquipBest", function(player)
		return self:EquipBest(player):expect()
	end)
end

function PetService.EquipBest(self: PetService, player: Player)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return Promise.all(Sift.Dictionary.map(saveFile:Get("Pets").Equipped, function(_, slotId)
			return self:SetPetEquipped(player, slotId, false)
		end))
			:andThen(function()
				local owned = saveFile:Get("Pets").Owned
				local bestSlotIds = Sift.Array.sort(Sift.Dictionary.keys(owned), function(idA, idB)
					local slotA, slotB = owned[idA], owned[idB]
					local powerA, powerB = PetHelper.GetPetPower(slotA.PetId, slotA.Tier), PetHelper.GetPetPower(slotB.PetId, slotB.Tier)
					return powerA > powerB
				end)

				return Promise.all(Sift.Array.map(Range(3), function(index)
					local slotId = bestSlotIds[index]
					if not slotId then return end

					return self:SetPetEquipped(player, slotId, true)
				end))
			end)
			:andThenReturn(true)
	end)
end

function PetService.AddPet(self: PetService, player: Player, petId: string, tier: number?)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Pets", function(pets)
			local hash = PetHelper.InfoToHash(petId, tier or 0)

			return Sift.Dictionary.update(pets, "Owned", function(owned)
				return Sift.Dictionary.update(owned, hash, function(value)
					value = (value or 0) + 1
				end)
			end)
		end)

		return OptionsService:GetOption(player, "AutoEquipBestPets"):andThen(function(autoEquip)
			if not autoEquip then return end

			return self:EquipBest(player)
		end)
	end)
end

function PetService.MergePets(self: PetService, player: Player, hash: string, count: number)
	return self:GetPets(player):andThen(function(pets)
		local countOwned = pets.Owned[hash] or 0

		if countOwned < count then return false end

		local roll = Rand:NextInteger(1, 4) - count
		local success = roll < 1

		local petId, tier = PetHelper.HashToInfo(hash)

		return EffectService:Effect(
			player,
			EffectGrindPets({
				PetId = petId,
				Success = success,
				Count = count,
			})
		)
			:andThen(function()
				return self:RemovePet(player, hash, count)
			end)
			:andThen(function()
				if success then
					return self:AddPet(player, petId, tier + 1):andThenReturn(true)
				else
					return OptionsService:GetOption(player, "AutoEquipBestPets")
						:andThen(function(autoEquip)
							if not autoEquip then return end

							return self:EquipBest(player)
						end)
						:andThenReturn(false)
				end
			end)
	end)
end

function PetService.GetMaxPetSlots(_self: PetService, _player: Player)
	return Promise.resolve(3)
end

function PetService.EquipPet(self: PetService, player: Player, hash: string)
	return Promise.all({
		DataService:GetSaveFile(player),
		self:GetMaxPetSlots(player),
	}):andThen(function(results)
		local saveFile, maxSlots = unpack(results)

		local pets = saveFile:Get("Pets")

		local total = 0
		for _, count in pets.Equipped do
			total += count
		end
		if total >= maxSlots then return false end

		local equippedCount = pets.Equipped[hash] or 0
		if equippedCount >= pets.Owned[hash] then return false end

		saveFile:Set(
			"Pets",
			Sift.Dictionary.update(pets, "Equipped", function(equipped)
				return Sift.Dictionary.set(equipped, hash, equippedCount + 1)
			end)
		)

		return true
	end)
end

function PetService.UnequipPet(self: PetService, player: Player, hash: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local pets = saveFile:Get("Pets")

		local equippedCount = pets.Equipped[hash] or 0
		if equippedCount <= 0 then return false end

		saveFile:Set(
			"Pets",
			Sift.Dictionary.update(pets, "Equipped", function(equipped)
				return Sift.Dictionary.update(equipped, hash, function(count)
					if count == 1 then
						return nil
					else
						return count - 1
					end
				end)
			end)
		)

		return true
	end)
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

function PetService.RemovePet(self: PetService, player: Player, hash: string, count: number?)
	if count == nil then count = 1 end

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Pets", function(pets)
			if pets.Owned[hash] < count then return pets end

			pets = Sift.Dictionary.update(pets.Owned, function(owned)
				return Sift.Dictionary.update(owned, hash, function(countOwned)
					if countOwned == count then
						return nil
					else
						return countOwned - count
					end
				end)
			end)

			pets = Sift.Dictionary.update(pets.Equipped, function(equipped)
				return Sift.Dictionary.update(equipped, hash, function(countEquipped)
					if countEquipped == nil then return nil end
					if pets.Owned[hash] == 0 then return nil end

					return math.min(pets.Owned[hash], countEquipped)
				end)
			end)

			return pets
		end)
	end)
end

function PetService.HatchPetFromGacha(self: PetService, player: Player, gachaId: string)
	local gacha = PetGachaDefs[gachaId]
	assert(gacha, `No gacha with id {gachaId}`)

	return CurrencyService:ApplyPrice(player, gacha.Price)
		:andThen(function(success)
			if not success then return false, "notEnoughCurrency" end

			EventStream.Event({ Kind = "PetGachaRolled", Player = player, GachaId = gachaId })

			local petId = gacha.WeightTable:Roll()
			return self:AddPet(player, petId):andThenReturn(true, petId)
		end)
		:catch(function(problem)
			warn(problem)
			return false, "error"
		end)
end

return PetService
