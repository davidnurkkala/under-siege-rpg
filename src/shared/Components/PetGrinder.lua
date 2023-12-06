local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)

local PetGrinder = {}
PetGrinder.__index = PetGrinder

export type PetGrinder = typeof(setmetatable(
	{} :: {
		Animator: Animator.Animator,
		Root: BasePart,
	},
	PetGrinder
))

function PetGrinder.new(model): PetGrinder
	local animator = Animator.new(model:FindFirstChild("AnimationController"))

	local self: PetGrinder = setmetatable({
		Animator = animator,
		Root = model.PrimaryPart,
	}, PetGrinder)

	self.Animator:Play("GrinderIdle")

	return self
end

function PetGrinder.GetPosition(self: PetGrinder)
	return self.Root.Position
end

function PetGrinder.Destroy(self: PetGrinder)
	self.Animator:Destroy()
end

return PetGrinder
