local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Pets = {
	Bunny = {
		Name = "Bunny",
		ModelName = "BunnyPet",
		Power = 1.6,
	},
	Doggy = {
		Name = "Doggy",
		ModelName = "DoggyPet",
		Power = 1,
	},
	Kitty = {
		Name = "Kitty",
		ModelName = "KittyPet",
		Power = 1.2,
	},
	Piggy = {
		Name = "Piggy",
		ModelName = "PiggyPet",
		Power = 1.4,
	},
	Wolfy = {
		Name = "Wolfy",
		ModelName = "WolfyPet",
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
