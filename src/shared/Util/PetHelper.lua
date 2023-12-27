local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)

local PetHelper = {}

function PetHelper.GetPetPower(petId, tier)
	local petDef = PetDefs[petId]
	assert(petDef, `No pet def with id {petId}`)

	return petDef.Power * math.sqrt(tier)
end

function PetHelper.GetTotalPower(pets)
	if pets == nil then return 1 end

	local power = 1
	for hash, count in pets.Equipped do
		power += PetHelper.GetPetPower(PetHelper.HashToInfo(hash)) * count
	end
	return power
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

function PetHelper.SortByPower(hashA, hashB)
	return PetHelper.GetPetPower(PetHelper.HashToInfo(hashA)) > PetHelper.GetPetPower(PetHelper.HashToInfo(hashB))
end

return PetHelper
