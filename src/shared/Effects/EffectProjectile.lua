local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local EffectFadeModel = require(ReplicatedStorage.Shared.Effects.EffectFadeModel)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(args: {
	Model: Model,
	Start: CFrame,
	Finish: CFrame,
	Speed: number,
})
	local duration = (args.Finish.Position - args.Start.Position).Magnitude / args.Speed

	return function()
		return script.Name, args, Promise.delay(duration)
	end, function()
		local model = args.Model:Clone()
		model.Parent = workspace.Effects

		return Animate(duration, function(scalar)
			model:PivotTo(args.Start:Lerp(args.Finish, scalar))
		end):andThenCall(function()
			EffectController:Effect(EffectFadeModel({
				Model = model,
			}))
		end)
	end
end
