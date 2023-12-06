local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local ComponentController = require(ReplicatedStorage.Shared.Controllers.ComponentController)
local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local EffectFadeModel = require(ReplicatedStorage.Shared.Effects.EffectFadeModel)
local EffectPart = require(ReplicatedStorage.Shared.Util.EffectPart)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local Promise = require(ReplicatedStorage.Packages.Promise)
local RandomSpin = require(ReplicatedStorage.Shared.Util.RandomSpin)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)

return function(args: {
	PetId: string,
})
	return function()
		return script.Name, args, Promise.delay(3)
	end, function()
		local grinders = ComponentController:GetComponentsByName("PetGrinder")
		local playerRoot = Players.LocalPlayer.Character.PrimaryPart

		local here = playerRoot.Position
		local bestGrinder = nil
		local bestDistance = math.huge

		for _, grinder in grinders do
			local distance = (grinder:GetPosition() - here).Magnitude
			if distance < bestDistance then
				bestGrinder = grinder
				bestDistance = distance
			end
		end

		bestGrinder.Animator:Play("GrinderShake")

		local def = PetDefs[args.PetId]

		return Promise.new(function(resolve, _, onCancel)
			for _ = 1, 3 do
				local model = def.Model:Clone()
				model.Parent = workspace.Effects

				local spin = RandomSpin()

				Animate(0.5, function(scalar)
					local position = Lerp(bestGrinder.Root.InputPoint.WorldPosition, bestGrinder.Root.DescentPoint.WorldPosition, math.pow(scalar, 2))
					model:PivotTo(spin + position)
				end):andThen(function()
					model:Destroy()
				end)

				task.wait(0.75)
				if onCancel() then return end
			end

			resolve()
		end)
			:andThen(function()
				local model = Instance.new("Model")
				model.Name = "DroppedPet"

				local root = EffectPart()
				root.Name = "Root"
				root.Anchored = false
				root.CanCollide = true
				root.CFrame = RandomSpin() + bestGrinder.Root.OutputPoint.WorldPosition
				root.Size = Vector3.new(2, 2, 2)
				root.Transparency = 1
				root.Parent = model
				model.PrimaryPart = root

				for _, object in def.Model:GetDescendants() do
					if not object:IsA("BasePart") then continue end

					local offset = def.Model:GetPivot():ToObjectSpace(object.CFrame)

					local part = object:Clone()
					part.Name = "Decoration"
					part.CanCollide = false
					part.Anchored = false
					part.CanQuery = false
					part.CanTouch = false
					part.CFrame = root.CFrame * offset
					part.Parent = model

					local weld = Instance.new("WeldConstraint")
					weld.Part0 = root
					weld.Part1 = part
					weld.Parent = part
				end

				model.Parent = workspace

				Promise.delay(1):andThen(function()
					local start = root.Position
					root.Anchored = true
					root.CanCollide = false

					Animate(0.5, function(scalar)
						root.CFrame = root.CFrame.Rotation + Lerp(start, playerRoot.Position, math.pow(scalar, 2))
					end):andThen(function()
						model:Destroy()
					end)
				end)
			end)
			:finally(function()
				bestGrinder.Animator:Stop("GrinderShake")
			end)
	end
end
