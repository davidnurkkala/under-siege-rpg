local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationDefs = require(ReplicatedStorage.Shared.Defs.AnimationDefs)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)

local AnimatedModel = {}
AnimatedModel.__index = AnimatedModel

export type AnimatedModel = typeof(setmetatable({} :: {
	Animator: Animator.Animator,
}, AnimatedModel))

function AnimatedModel.new(model: Model): AnimatedModel
	local animator = model:FindFirstChildWhichIsA("AnimationController") or model:FindFirstChildWhichIsA("Humanoid")
	assert(animator, `AnimatedModel {model:GetFullName()} has no AnimationController or Humanoid`)

	local animationName = model:GetAttribute("Animation")
	assert(animationName, `AnimatedModel {model:GetFullName()} has no animation attribute`)
	local animation = AnimationDefs[animationName]
	assert(animation, `AnimatedModel {model:GetFullName()} has animation {animationName} which was not found in AnimationDefs`)

	local self: AnimatedModel = setmetatable({
		Animator = Animator.new(animator),
	}, AnimatedModel)

	self.Animator:Play(animationName)

	return self
end

function AnimatedModel.Destroy(self: AnimatedModel)
	self.Animator:Destroy()
end

return AnimatedModel
