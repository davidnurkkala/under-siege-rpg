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
	return Sift.Array.reduce(Sift.Dictionary.keys(pets.Equipped), function(power, slotId)
		local slot = pets.Owned[slotId]
		return power * PetHelper.GetPetPower(slot.PetId, slot.Tier)
	end, 1)
end

return PetHelper
