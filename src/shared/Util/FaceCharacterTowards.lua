local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

return function(root: BasePart, position: Vector3)
	return Promise.try(function()
		local here = root.Position
		local delta = (position - here) * Vector3.new(1, 0, 1)
		local there = here + delta
		root.CFrame = CFrame.lookAt(here, there)
	end)
end
