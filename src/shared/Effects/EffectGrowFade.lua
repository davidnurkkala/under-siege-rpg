local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(args: {
	Part: BasePart,
	Target: CFrame | BasePart,
	StartSize: Vector3,
	EndSize: Vector3,
	Duration: number,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local getCFrame = if typeof(args.Target) == "CFrame"
			then function()
				return args.Target
			end
			else function()
				return args.Target.CFrame
			end

		local part = args.Part:Clone()
		local transparency = part.Transparency
		part.Parent = workspace.Effects

		Animate(args.Duration, function(scalar)
			part.CFrame = getCFrame()
			part.Size = Lerp(args.StartSize, args.EndSize, math.pow(scalar, 0.5))
			part.Transparency = Lerp(transparency, 1, scalar)
		end):andThen(function()
			part:Destroy()
		end)
	end
end
