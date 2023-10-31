local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PromisesByModel = {}
local Random = Random.new()

return function(args: {
	Model: Model,
	Intensity: number,
	Duration: number,
})
	return function()
		return script.Name, args, Promise.delay(args.Duration)
	end, function()
		local model = args.Model
		local intensity = args.Intensity
		local duration = args.Duration

		if PromisesByModel[model] then
			PromisesByModel[model]:cancel()
			PromisesByModel[model] = nil
		end

		local trove = Trove.new()

		local lastDelta

		local function unjitter()
			if lastDelta then
				model:TranslateBy(-lastDelta)
				lastDelta = nil
			end
		end

		local start = tick()

		trove:BindToRenderStep(Guid(), Enum.RenderPriority.Last.Value, function()
			unjitter()

			local passed = tick() - start
			local scalar = math.clamp(passed / duration, 0, 1)

			lastDelta = Random:NextUnitVector() * Lerp(intensity, 0, scalar)
			model:TranslateBy(lastDelta)
		end)

		trove:Add(unjitter)

		PromisesByModel[model] = Promise.delay(duration)
			:finally(function()
				trove:Clean()
			end)
			:andThen(function()
				PromisesByModel[model] = nil
			end)
	end
end
