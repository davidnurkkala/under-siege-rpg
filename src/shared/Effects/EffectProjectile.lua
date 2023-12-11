local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local EffectFadeModel = require(ReplicatedStorage.Shared.Effects.EffectFadeModel)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(args: {
	Model: Model,
	Start: BasePart | CFrame,
	Finish: BasePart | CFrame,
	Speed: number,
})
	local duration = (args.Finish.Position - args.Start.Position).Magnitude / args.Speed

	return function()
		return script.Name, args, Promise.delay(duration)
	end, function()
		local model = args.Model:Clone()
		model.Parent = workspace.Effects

		local start = if typeof(args.Start) == "CFrame"
			then function()
				return args.Start
			end
			else function()
				return args.Start.CFrame
			end

		local finish = if typeof(args.Finish) == "CFrame"
			then function()
				return args.Finish
			end
			else function()
				return args.Finish.CFrame
			end

		local startRotation = Vector3.new(0, 0, 0)
		local finishRotation = (model:GetAttribute("Rotation") or Vector3.new()) * duration
		local doesRotate = startRotation ~= finishRotation

		return Animate(duration, function(scalar)
			local position = Lerp(start().Position, finish().Position, scalar)
			local cframe = CFrame.lookAt(position, finish().Position).Rotation + position

			if doesRotate then
				local rotation = Lerp(startRotation, finishRotation, scalar)
				cframe *= CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
			end

			model:PivotTo(cframe)
		end):andThenCall(function()
			EffectController:Effect(EffectFadeModel({
				Model = model,
			}))
		end)
	end
end
