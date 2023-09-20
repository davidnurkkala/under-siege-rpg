local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(args: {
	Model: Model,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local fadeTime = 0

		local fadeCallbacks = Sift.Array.map(args.Model:GetDescendants(), function(object)
			if object:IsA("Trail") then
				object.Enabled = false
				fadeTime = math.max(fadeTime, object.Lifetime)
			elseif object:IsA("ParticleEmitter") then
				object.Enabled = false
				fadeTime = math.max(fadeTime, object.Lifetime.Max)
			elseif object:IsA("PointLight") then
				return function(duration)
					local range = object.Range
					return Animate(duration, function(scalar)
						object.Range = Lerp(range, 0, scalar)
					end)
				end
			elseif object:IsA("BasePart") then
				return function(duration)
					local t = object.Transparency
					return Animate(duration, function(scalar)
						object.Transparency = Lerp(t, 1, scalar)
					end)
				end
			end

			return
		end)

		return Promise.all(Sift.Array.append(
			Sift.Array.map(fadeCallbacks, function(callback)
				return callback(fadeTime)
			end),
			Promise.delay(fadeTime)
		)):andThen(function()
			args.Model:Destroy()
		end)
	end
end
