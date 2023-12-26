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
		Power = 0.6,
	},
	Doggy = {
		Name = "Doggy",
		ModelName = "DoggyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "DoggyIdleExtras" },
			Walk = { "GenericPetWalk", "DoggyWalkExtras" },
		},
		Power = 0.1,
	},
	Kitty = {
		Name = "Kitty",
		ModelName = "KittyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyIdleExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 0.2,
	},
	Piggy = {
		Name = "Piggy",
		ModelName = "PiggyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "PiggyIdleExtras" },
			Walk = { "GenericPetWalk", "PiggyWalkExtras" },
		},
		Power = 0.4,
	},
	Wolfy = {
		Name = "Wolfy",
		ModelName = "WolfyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "WolfyIdleExtras" },
			Walk = { "GenericPetWalk", "WolfyWalkExtras" },
		},
		Power = 1,
	},

	Bull = {
		Name = "Bully",
		ModelName = "BullPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "DoggyIdleExtras" },
			Walk = { "GenericPetWalk", "DoggyWalkExtras" },
		},
		Power = 1.2,
	},

	Lion = {
		Name = "Liony",
		ModelName = "LionPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyIdleExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 1.4,
	},

	Rhino = {
		Name = "Rhiny",
		ModelName = "RhinoPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "WolfyIdleExtras" },
			Walk = { "GenericPetWalk", "WolfyWalkExtras" },
		},
		Power = 1.6,
	},

	Slime = {
		Name = "Slimey",
		ModelName = "SlimePet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "WolfyIdleExtras" },
			Walk = { "GenericPetWalk", "WolfyWalkExtras" },
		},
		Power = 1.8,
	},

	Goat = {
		Name = "Goaty",
		ModelName = "GoatPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "DoggyIdleExtras" },
			Walk = { "GenericPetWalk", "DoggyWalkExtras" },
		},
		Power = 2,
	},

	Fox = {
		Name = "Foxy",
		ModelName = "FoxPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyIdleExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 2.2,
	},

	Mouse = {
		Name = "Mousy",
		ModelName = "MousePet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyWalkExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 2.4,
	},

	Bat = {
		Name = "Batsy",
		ModelName = "BatPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "BatIdleExtras" },
			Walk = { "GenericPetWalk", "BatWalkExtras" },
		},
		Power = 2.6,
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
