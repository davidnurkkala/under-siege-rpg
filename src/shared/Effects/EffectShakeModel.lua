local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Shake = require(ReplicatedStorage.Packages.Shake)

local ShakesByModel = {}

return function(args: {
	Model: Model,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local model = args.Model

		local shake = ShakesByModel[model]
		if shake then
			shake:Stop()
			ShakesByModel[model] = nil
		end

		local shaker = Shake.new()
		shaker.FadeInTime = 0
		shaker.FadeOutTime = 0.25
		shaker.Frequency = 0.1
		shaker.Amplitude = 3
		shaker.RotationInfluence = Vector3.new(1, 1, 1)

		shake = {
			OriginalPivot = model:GetPivot(),
			Shaker = shaker,
			Stop = function(self)
				self.Shaker:Stop()
				model:PivotTo(self.OriginalPivot)
				ShakesByModel[model] = nil
			end,
		}
		ShakesByModel[model] = shake

		shaker:Start()
		shaker:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(_, rot, isDone)
			if isDone then
				shake:Stop()
				ShakesByModel[model] = nil
			else
				model:PivotTo(shake.OriginalPivot * CFrame.Angles(rot.X, rot.Y, rot.Z))
			end
		end)
	end
end
