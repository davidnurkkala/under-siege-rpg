local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldService = {
	Priority = 0,
}

type WorldService = typeof(WorldService)

function WorldService.PrepareBlocking(self: WorldService)
	local ocean = Instance.new("Folder")
	ocean.Name = "Ocean"
	ocean.Parent = workspace

	local oceanRadius = 2
	local oceanCellSize = 2048
	for x = -oceanRadius, oceanRadius do
		for z = -oceanRadius, oceanRadius do
			local oceanCell = ReplicatedStorage.Assets.Models.Ocean:Clone()
			oceanCell:PivotTo(CFrame.new(x * oceanCellSize, -20, z * oceanCellSize))
			oceanCell.Parent = ocean
		end
	end

	self.Worlds = {
		self:CreateWorld("World1", CFrame.new(0, 0, 0)),
		self:CreateWorld("World2", CFrame.new(512, 0, 1024)),
	}
end

function WorldService.CreateWorld(self: WorldService, name, cframe)
	local model = ReplicatedStorage.Assets.Worlds:FindFirstChild(name)
	assert(model, `No world by name {name}`)

	model = model:Clone()
	model:PivotTo(cframe)
	model.Parent = workspace

	return model
end

return WorldService
