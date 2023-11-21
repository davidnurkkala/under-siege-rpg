local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(args: {
	CharModel: Model,
	BaseModel: Model,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local cframe = args.CharModel:GetPivot()
		local baseOffset = cframe:ToObjectSpace(args.BaseModel:GetPivot())

		Animate(3, function(scalar)
			local jitter = math.cos(Lerp(32, 64, scalar) * math.pi * scalar) * Lerp(0, 0.5, scalar)
			local fall = Lerp(0, -4, scalar ^ 2)
			local delta = Vector3.new(jitter, fall, 0)

			local newCFrame = cframe + delta
			args.CharModel:PivotTo(newCFrame)
			args.BaseModel:PivotTo(newCFrame:ToWorldSpace(baseOffset))
		end)
	end
end
