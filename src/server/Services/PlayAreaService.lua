local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayAreaService = {
	Priority = 0,
}

type PlayAreaService = typeof(PlayAreaService)

function PlayAreaService.Start(_self: PlayAreaService)
	local playArea = ReplicatedStorage.Assets.Models.PlayArea:Clone()
	playArea:PivotTo(CFrame.new())
	playArea.Parent = workspace
end

return PlayAreaService
