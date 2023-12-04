local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Worlds = {
	World1 = {
		Name = "Viking Island",
		Order = 1,
		ModelName = "World1",
		Price = 0,
		Position = Vector3.new(0, 0, 0),
	},
	World2 = {
		Name = "Elven Woods",
		Order = 2,
		ModelName = "World2",
		Price = 1000,
		Position = Vector3.new(512, 0, 1024),
	},
	World3 = {
		Name = "Orcish Highalnds",
		Order = 3,
		ModelName = "World2",
		Price = 10000,
		Position = Vector3.new(-512, 0, 1024),
	},
}

return Sift.Dictionary.map(Worlds, function(world, id)
	world.Id = id
	world.Model = ReplicatedStorage.Assets.Worlds:FindFirstChild(world.ModelName)

	return world, id
end)
