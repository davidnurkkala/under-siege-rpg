local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local PetHelper = {}

function PetHelper.GetPetPower(petId, tier)
	local petDef = PetDefs[petId]
	assert(petDef, `No pet def with id {petId}`)

	return petDef.Power * math.sqrt(tier)
end

function PetHelper.GetTotalPower(pets)
	if pets == nil then return 1 end

	return Sift.Array.reduce(Sift.Dictionary.keys(pets.Equipped), function(power, slotId)
		local slot = pets.Owned[slotId]
		return power * PetHelper.GetPetPower(slot.PetId, slot.Tier)
	end, 1)
end

function PetHelper.InfoToHash(petId: string, tier: number): string
	return `{petId}_{tier}`
end

function PetHelper.HashToInfo(hash: string): (string, number)
	local data = string.split(hash, "_")
	local petId = data[1]
	local tier = tonumber(data[2])
	return petId, tier
end

return PetHelper
