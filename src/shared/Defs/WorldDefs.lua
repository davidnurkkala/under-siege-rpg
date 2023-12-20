local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Worlds = {
	World1 = {
		Name = "Grassy Kingdom",
		Order = 1,
		ModelName = "World1",
		LightingName = "World1",
		Price = 0,
		Position = Vector3.new(0, 0, 0),
	},
	World2 = {
		Name = "Viking Mountains",
		Order = 2,
		ModelName = "World2",
		LightingName = "World1",
		Price = 1000,
		Position = Vector3.new(512, 16, 1280),
	},
	World3 = {
		Name = "Elven Woods",
		Order = 3,
		ModelName = "World3",
		LightingName = "World1",
		Price = 10000,
		Position = Vector3.new(-640, 0, 1024),
	},
	World4 = {
		Name = "Orcish Highalnds",
		Order = 4,
		ModelName = "World4",
		LightingName = "World1",
		Price = 50000,
		Position = Vector3.new(-640, 0, -1024),
	},
}

return Sift.Dictionary.map(Worlds, function(world, id)
	world.Id = id
	world.Model = ReplicatedStorage.Assets.Worlds:FindFirstChild(world.ModelName)

	return world, id
end)
