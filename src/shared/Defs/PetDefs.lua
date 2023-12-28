local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Pets = {
	-- rank 1
	Doggy = {
		Name = "Doggy",
		ModelName = "DoggyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "DoggyIdleExtras" },
			Walk = { "GenericPetWalk", "DoggyWalkExtras" },
		},
		Power = 0.75,
	},
	Kitty = {
		Name = "Kitty",
		ModelName = "KittyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyIdleExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 1.5,
	},
	Piggy = {
		Name = "Piggy",
		ModelName = "PiggyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "PiggyIdleExtras" },
			Walk = { "GenericPetWalk", "PiggyWalkExtras" },
		},
		Power = 2.25,
	},
	Bunny = {
		Name = "Bunny",
		ModelName = "BunnyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "BunnyIdleExtras" },
			Walk = { "GenericPetWalk", "BunnyWalkExtras" },
		},
		Power = 3,
	},

	-- rank 2
	Bully = {
		Name = "Bully",
		ModelName = "BullPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "DoggyIdleExtras" },
			Walk = { "GenericPetWalk", "DoggyWalkExtras" },
		},
		Power = 4.5,
	},
	Liony = {
		Name = "Liony",
		ModelName = "LionPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyIdleExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 5.25,
	},
	Rhiny = {
		Name = "Rhiny",
		ModelName = "RhinoPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "WolfyIdleExtras" },
			Walk = { "GenericPetWalk", "WolfyWalkExtras" },
		},
		Power = 6,
	},
	Wolfy = {
		Name = "Wolfy",
		ModelName = "WolfyPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "WolfyIdleExtras" },
			Walk = { "GenericPetWalk", "WolfyWalkExtras" },
		},
		Power = 6.75,
	},

	-- rank 3
	Goaty = {
		Name = "Goaty",
		ModelName = "GoatPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "DoggyIdleExtras" },
			Walk = { "GenericPetWalk", "DoggyWalkExtras" },
		},
		Power = 8.25,
	},
	Mousey = {
		Name = "Mousey",
		ModelName = "MousePet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyWalkExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 9,
	},
	Batsy = {
		Name = "Batsy",
		ModelName = "BatPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "BatIdleExtras" },
			Walk = { "GenericPetWalk", "BatWalkExtras" },
		},
		Power = 9.75,
	},
	Foxy = {
		Name = "Foxy",
		ModelName = "FoxPet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "KittyIdleExtras" },
			Walk = { "GenericPetWalk", "KittyWalkExtras" },
		},
		Power = 10.5,
	},

	-- rank 4
	Slimey = {
		Name = "Slimey",
		ModelName = "SlimePet",
		Animations = {
			Idle = { "GenericPetBlink", "GenericPetIdle", "WolfyIdleExtras" },
			Walk = { "GenericPetWalk", "WolfyWalkExtras" },
		},
		Power = 12,
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
