local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local function startClientBlocking()
	local controllers = Sift.Array.sort(Sift.Array.map(ReplicatedStorage.Shared.Controllers:GetChildren(), require), function(a, b)
		return a.Priority < b.Priority
	end)

	for _, controllerToPrepare in
		Sift.Array.filter(controllers, function(service)
			return Sift.Dictionary.has(service, "PrepareBlocking")
		end)
	do
		controllerToPrepare:PrepareBlocking()
	end

	for _, service in controllers do
		task.spawn(service.Start, service)
	end
end

startClientBlocking()
