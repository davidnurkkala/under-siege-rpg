local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Pet = {}
Pet.__index = Pet

export type Pet = typeof(setmetatable({} :: {
	Model: Model,
	Animator: Animator,
	Trove: any,
	Def: any,
}, Pet))

function Pet.new(petId: string, root: BasePart, human: Humanoid, cframe: CFrame): Pet
	local petDef = PetDefs[petId]
	assert(petDef, `No def found for pet id {petId}`)

	local trove = Trove.new()

	local model = trove:Clone(petDef.Model)
	model:PivotTo(cframe)
	model.Parent = root.Parent

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = model.PrimaryPart
	weld.Parent = model.PrimaryPart

	local animator = trove:Construct(Animator, model:FindFirstChildWhichIsA("AnimationController"))

	local self: Pet = setmetatable({
		Trove = trove,
		Model = model,
		Animator = animator,
		Def = petDef,
	}, Pet)

	for _, animationName in self.Def.Animations.Idle do
		animator:Play(animationName)
	end

	local isPlaying = false
	trove:Connect(human.Running, function(speed)
		local playing = speed > 1.5

		if playing == isPlaying then return end
		isPlaying = playing

		for _, animationName in self.Def.Animations.Walk do
			if playing then
				animator:Play(animationName, nil, nil, 2)
			else
				animator:Stop(animationName)
			end
		end
	end)

	return self
end

function Pet.Destroy(self: Pet)
	self.Trove:Clean()
end

return Pet
