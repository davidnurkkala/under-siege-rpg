local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Pets = {
	Bunny = {
		Name = "Bunny",
		ModelName = "BunnyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "BunnyIdleExtras" },
			Walk = { "GenericPetWalk", "BunnyWalkExtras" },
		},
		Power = 1.6,
	},
	Doggy = {
		Name = "Doggy",
		ModelName = "DoggyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "DoggyIdleExtras" },
			Walk = { "GenericPetWalk", "DoggyWalkExtras" },
		},
		Power = 1,
	},
	Kitty = {
		Name = "Kitty",
		ModelName = "KittyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyIdleExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 1.2,
	},
	Piggy = {
		Name = "Piggy",
		ModelName = "PiggyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "PiggyIdleExtras" },
			Walk = { "GenericPetWalk", "PiggyWalkExtras" },
		},
		Power = 1.4,
	},
	Wolfy = {
		Name = "Wolfy",
		ModelName = "WolfyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "WolfyIdleExtras" },
			Walk = { "GenericPetWalk", "WolfyWalkExtras" },
		},
		Power = 2,
	},
}

return Sift.Dictionary.map(Pets, function(pet, id)
	local model = ReplicatedStorage.Assets.Models.Pets:FindFirstChild(pet.ModelName)
	assert(model, `No model found with name {pet.ModelName}`)

	return Sift.Dictionary.merge(pet, {
		Id = id,
		Model = model,
	})
end)
