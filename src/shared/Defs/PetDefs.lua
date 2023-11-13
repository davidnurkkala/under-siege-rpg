local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Pets = {
	Bunny = {
		Name = "Bunny",
		ModelName = "BunnyPet",
		Rank = 1,
	},
	Doggy = {
		Name = "Doggy",
		ModelName = "DoggyPet",
		Rank = 1,
	},
	Kitty = {
		Name = "Kitty",
		ModelName = "KittyPet",
		Rank = 1,
	},
	Piggy = {
		Name = "Piggy",
		ModelName = "PiggyPet",
		Rank = 1,
	},
	Wolfy = {
		Name = "Wolfy",
		ModelName = "WolfyPet",
		Rank = 2,
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
