local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local ComponentController = require(ReplicatedStorage.Shared.Controllers.ComponentController)
local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectPart = require(ReplicatedStorage.Shared.Util.EffectPart)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local Promise = require(ReplicatedStorage.Packages.Promise)
local RandomSpin = require(ReplicatedStorage.Shared.Util.RandomSpin)

local function getMainColor(model)
	local massByColor = {}

	for _, object in model:GetDescendants() do
		if not object:IsA("BasePart") then continue end

		print(object, object:GetMass(), object.Color)

		local color = object.Color:ToHex()
		local size = object.Size
		local mass = size.X * size.Y * size.Z * (1 - object.Transparency)

		massByColor[color] = (massByColor[color] or 0) + mass
	end

	local bestColor, bestMass = nil, 0
	for color, mass in massByColor do
		if mass > bestMass then
			bestMass = mass
			bestColor = color
		end
	end

	return Color3.fromHex(bestColor)
end

return function(args: {
	PetId: string,
	Success: boolean,
	Count: number,
})
	return function()
		return script.Name, args, Promise.delay(0.75 * args.Count + 1.5)
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
			for _ = 1, args.Count do
				local model = def.Model:Clone()
				model.Parent = workspace.Effects

				local spin = RandomSpin()

				Animate(0.5, function(scalar)
					local position = Lerp(bestGrinder.Root.InputPoint.WorldPosition, bestGrinder.Root.DescentPoint.WorldPosition, math.pow(scalar, 2))
					model:PivotTo(spin + position)
				end):andThen(function()
					model:Destroy()
				end)

				Animate(0.1, function(scalar)
					model:ScaleTo(Lerp(0.1, 1, scalar))
				end)

				Promise.delay(0.1):andThen(function()
					EffectController:Effect(EffectSound({
						Target = bestGrinder.Root.DescentPoint,
						SoundId = "MasherMash1",
					}))

					local emitter = ReplicatedStorage.Assets.Emitters.PetChunks1:Clone()
					emitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
					emitter.Parent = bestGrinder.Root.DescentPoint
					Promise.delay(0.5):andThen(function()
						emitter.Enabled = false
						task.wait(emitter.Lifetime.Max)
						emitter:Destroy()
					end)
				end)

				task.wait(0.75)
				if onCancel() then return end
			end

			resolve()
		end)
			:andThen(function()
				if not args.Success then
					EffectController:Effect(EffectEmission({
						Target = bestGrinder.Root.OutputPoint,
						Emitter = ReplicatedStorage.Assets.Emitters.Poof1,
						ParticleCount = 6,
					}))
					EffectController:Effect(EffectSound({
						Target = bestGrinder.Root.OutputPoint,
						SoundId = "CartoonPoof1",
					}))
					return
				end

				EffectController:Effect(EffectSound({
					Target = bestGrinder.Root.OutputPoint,
					SoundId = "CartoonPop1",
				}))

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

				Animate(0.1, function(scalar)
					model:ScaleTo(Lerp(0.1, 1, scalar))
				end)

				Promise.delay(1):andThen(function()
					local start = root.Position
					root.Anchored = true
					root.CanCollide = false

					Animate(0.5, function(scalar)
						scalar = math.pow(scalar, 2)
						root.CFrame = root.CFrame.Rotation + Lerp(start, playerRoot.Position, scalar)
						model:ScaleTo(Lerp(1, 0.01, scalar))
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
