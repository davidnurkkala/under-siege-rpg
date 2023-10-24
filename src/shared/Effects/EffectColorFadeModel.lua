local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)

local PromisesByModel = {}

return function(args: {
	Model: Model,
	Color: Color3,
	Duration: number,
})
	return function()
		return script.Name, args, Promise.delay(args.Duration)
	end, function()
		local model = args.Model
		local color = args.Color
		local duration = args.Duration

		if PromisesByModel[model] then
			PromisesByModel[model]:cancel()
			PromisesByModel[model] = nil
		end

		PromisesByModel[model] = Promise.all(Sift.Array.map(
			Sift.Array.filter(model:GetDescendants(), function(object)
				return object:IsA("BasePart")
			end),
			function(part)
				local goalColor = part.Color
				return Animate(duration, function(scalar)
					part.Color = color:Lerp(goalColor, scalar)
				end):finally(function()
					part.Color = goalColor
				end)
			end
		)):andThen(function()
			PromisesByModel[model] = nil
		end)
	end
end
