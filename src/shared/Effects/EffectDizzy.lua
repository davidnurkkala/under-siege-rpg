local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local EffectFadeModel = require(ReplicatedStorage.Shared.Effects.EffectFadeModel)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(args: {
	Head: BasePart,
	Duration: number,
})
	return function()
		return script.Name, args, Promise.delay(args.Duration)
	end, function()
		local model = ReplicatedStorage.Assets.Models.Projectiles.MagicStar1:Clone()
		for _, object in model:GetDescendants() do
			if object:IsA("Light") then object:Destroy() end
		end
		model.Parent = workspace.Effects

		local rotationsPerSecond = 2
		local rotation = math.pi * 2 * rotationsPerSecond * args.Duration
		Promise.all({
			Animate(args.Duration, function(scalar)
				local theta = rotation * scalar
				model:PivotTo(args.Head.CFrame * CFrame.Angles(0, theta, 0) * CFrame.new(1.5, 0.5, 0))
			end),
			Promise.delay(args.Duration - 0.5):andThen(function()
				EffectController:Effect(EffectFadeModel({
					Model = model,
					FadeTime = 0.5,
				}))
			end),
		}):finally(function()
			model:Destroy()
		end)
	end
end
