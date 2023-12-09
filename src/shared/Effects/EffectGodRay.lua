local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

return function(args: {
	Beam: Beam,
	Length: number,
	Width: number,
	Target: BasePart,
	Duration: number,
})
	return function()
		return script.Name, args, Promise.delay(args.Duration)
	end, function()
		local trove = Trove.new()

		local bottom = trove:Construct(Instance, "Attachment")
		bottom.Parent = args.Target

		local top = trove:Construct(Instance, "Attachment")
		top.CFrame = CFrame.new(0, args.Length, 0)
		top.Parent = args.Target

		local beam: Beam = trove:Clone(args.Beam)
		beam.Attachment0 = top
		beam.Attachment1 = bottom
		beam.Parent = args.Target

		Animate(args.Duration, function(scalar)
			beam.Transparency = NumberSequence.new(math.pow(scalar, 2))

			local width = math.pow(scalar, 0.5) * args.Width
			beam.Width0 = width
			beam.Width1 = width
		end):andThen(function()
			trove:Clean()
		end)
	end
end
