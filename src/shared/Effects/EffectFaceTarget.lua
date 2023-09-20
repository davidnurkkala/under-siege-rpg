local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local FaceCharacterTowards = require(ReplicatedStorage.Shared.Util.FaceCharacterTowards)
local Promise = require(ReplicatedStorage.Packages.Promise)

local FacersByRoot = {}

return function(args: {
	Root: BasePart,
	Target: Vector3 | BasePart | Model,
	Duration: number,
})
	return function()
		return script.Name, args, Promise.delay(args.Duration)
	end, function()
		local getPosition = if typeof(args.Target) == "Vector3"
			then function()
				return args.Target
			end
			else if args.Target:IsA("Model")
				then function()
					return args.Target:GetPivot().Position
				end
				else function()
					return args.Target.Position
				end

		if FacersByRoot[args.Root] then
			FacersByRoot[args.Root]:cancel()
			FacersByRoot[args.Root] = nil
		end

		FacersByRoot[args.Root] = Animate(args.Duration, function()
			FaceCharacterTowards(args.Root, getPosition())
		end):andThen(function()
			FacersByRoot[args.Root] = nil
		end)
	end
end
