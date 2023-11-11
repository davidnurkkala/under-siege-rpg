local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldService = {
	Priority = 0,
}

type WorldService = typeof(WorldService)

function WorldService.PrepareBlocking(self: WorldService)
	local world1 = ReplicatedStorage.Assets.Worlds.World1:Clone()
	world1:PivotTo(CFrame.new())
	world1.Parent = workspace
end

return WorldService
