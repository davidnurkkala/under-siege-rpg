local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EffectGrindPets = require(ReplicatedStorage.Shared.Effects.EffectGrindPets)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local MultiRollHelper = require(ServerScriptService.Server.Util.MultiRollHelper)
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

	self.Comm:BindFunction("HatchPetFromGacha", function(player, gachaId, count)
		if not t.string(gachaId) then return end
		if not t.integer(count) then return end
		if count < 1 then return end
		if count > 1000 then return end

		return self:HatchPetFromGacha(player, gachaId, count):expect()
	end)

	self.Comm:BindFunction("EquipPet", function(player, hash)
		if not t.string(hash) then return end

		return self:EquipPet(player, hash):expect()
	end)

	self.Comm:BindFunction("UnequipPet", function(player, hash)
		if not t.string(hash) then return end

		return self:UnequipPet(player, hash):expect()
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
	return Promise.all({
		DataService:GetSaveFile(player),
		self:GetMaxPetSlots(player),
	}):andThen(function(results)
		local saveFile, slots = unpack(results)

		local pets = saveFile:Get("Pets")

		local bestHashes = Sift.Array.sort(Sift.Dictionary.keys(pets.Owned), PetHelper.SortByPower)

		local equipped = {}

		for _, hash in bestHashes do
			local used = math.min(pets.Owned[hash], slots)
			equipped[hash] = used

			slots -= used

			if slots == 0 then break end
		end

		pets = Sift.Dictionary.set(pets, "Equipped", equipped)

		saveFile:Set("Pets", pets)
	end)
end

function PetService.AddPet(self: PetService, player: Player, petId: string, tier: number?)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Pets", function(pets)
			local hash = PetHelper.InfoToHash(petId, tier or 1)

			return Sift.Dictionary.update(pets, "Owned", function(owned)
				return Sift.Dictionary.update(owned, hash, function(value)
					return value + 1
				end, function()
					return 1
				end)
			end)
		end)

		return OptionsService:GetOption(player, "AutoEquipBestPets"):andThen(function(autoEquip)
			if not autoEquip then return end

			return self:EquipBest(player)
		end)
	end)
end

function PetService.AddPets(self: PetService, player: Player, additions: { [string]: number })
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Pets", function(pets)
			return Sift.Dictionary.update(pets, "Owned", function(owned)
				for hash, count in additions do
					owned = Sift.Dictionary.update(owned, hash, function(oldCount)
						return oldCount + count
					end, function()
						return count
					end)
				end
				return owned
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
			:andThen(function(hadEnoughPets)
				if not hadEnoughPets then return false end

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

function PetService.GetPets(_self: PetService, player: Player)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("Pets")
	end)
end

function PetService.RemovePet(self: PetService, player: Player, hash: string, count: number?)
	if count == nil then count = 1 end

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local success = true

		saveFile:Update("Pets", function(pets)
			if pets.Owned[hash] < count then
				success = false
				return pets
			end

			pets = Sift.Dictionary.update(pets, "Owned", function(owned)
				return Sift.Dictionary.update(owned, hash, function(countOwned)
					if countOwned == count then
						return nil
					else
						return countOwned - count
					end
				end)
			end)

			pets = Sift.Dictionary.update(pets, "Equipped", function(equipped)
				return Sift.Dictionary.update(equipped, hash, function(countEquipped)
					if countEquipped == nil then return nil end
					if pets.Owned[hash] == nil then return nil end

					return math.min(pets.Owned[hash], countEquipped)
				end)
			end)

			return pets
		end)

		return success
	end)
end

function PetService.HatchPetFromGacha(self: PetService, player: Player, gachaId: string, countIn: number?)
	local gacha = PetGachaDefs[gachaId]
	assert(gacha, `No gacha with id {gachaId}`)

	local count = countIn or 1

	return Promise.new(function(resolve, _, onCancel)
		local check = MultiRollHelper.Check(player, count)
		onCancel(function()
			check:cancel()
		end)

		local canProceed = check:expect()
		if onCancel() then return end
		if not canProceed then
			resolve({})
			return
		end

		local additions = {}

		for _ = 1, count do
			local applyPrice = CurrencyService:ApplyPrice(player, gacha.Price)
			onCancel(function()
				applyPrice:cancel()
			end)

			local hadFunds = applyPrice:expect()
			if onCancel() then return end

			if not hadFunds then
				resolve(additions)
				return
			end

			local petId = gacha.WeightTable:Roll()
			local hash = PetHelper.InfoToHash(petId, 1)
			additions[hash] = (additions[hash] or 0) + 1
		end

		resolve(additions)
	end)
		:andThen(function(additions)
			if Sift.Dictionary.count(additions) == 0 then return false, "none" end

			EventStream.Event({ Kind = "PetGachaRolled", Player = player, GachaId = gachaId })

			return self:AddPets(player, additions):andThenReturn(true, additions)
		end)
		:catch(function(problem)
			warn(problem)
			return false, "error"
		end)
end

return PetService
