local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayAreaService = {
	Priority = 0,
}

local TrainingDummy: Model = nil
local Model: Model = nil

type PlayAreaService = typeof(PlayAreaService)

function PlayAreaService.Start(_self: PlayAreaService)
	Model = ReplicatedStorage.Assets.Models.PlayArea:Clone()
	Model:PivotTo(CFrame.new())
	Model.Parent = workspace

	TrainingDummy = Model:FindFirstChild("TrainingDummy") :: Model
end

function PlayAreaService.GetTrainingDummy(_self: PlayAreaService)
	return TrainingDummy
end

return PlayAreaService
