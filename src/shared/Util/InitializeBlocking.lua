local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

return function(folder)
	local modules = Sift.Array.sort(Sift.Array.map(folder:GetChildren(), require), function(a, b)
		return a.Priority < b.Priority
	end)

	for _, module in modules do
		if module.PrepareBlocking then module:PrepareBlocking() end
	end

	for _, module in modules do
		task.spawn(module.Start, module)
	end
end
