local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)

local AnimationsByModel = {}
local Duration = 1 / 30

return function(args: {
	Model: Model,
	CFrame: CFrame,
	StartCFrame: CFrame?,
})
	return function()
		local newArgs = Sift.Dictionary.set(args, "StartCFrame", args.Model:GetPivot())

		args.Model:PivotTo(args.CFrame)

		return script.Name, newArgs, Promise.resolve()
	end, function()
		local model = args.Model
		local cframe = args.CFrame
		local start = args.StartCFrame or model:GetPivot()

		if AnimationsByModel[model] then
			AnimationsByModel[model]:cancel()
			AnimationsByModel[model] = nil
		end

		AnimationsByModel[model] = Animate(Duration, function(scalar)
			model:PivotTo(start:Lerp(cframe, scalar))
		end):andThen(function()
			AnimationsByModel[model] = nil
		end)
	end
end
