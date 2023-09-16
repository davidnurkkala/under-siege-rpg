local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Sift = require(ReplicatedStorage.Packages.Sift)

local function startServerBlocking()
	local services = Sift.Array.sort(Sift.Array.map(ServerScriptService.Server.Services:GetChildren(), require), function(a, b)
		return a.Priority < b.Priority
	end)

	for _, serviceToPrepare in
		Sift.Array.filter(services, function(service)
			return Sift.Dictionary.has(service, "PrepareBlocking")
		end)
	do
		serviceToPrepare:PrepareBlocking()
	end

	for _, service in services do
		task.spawn(service.Start, service)
	end
end

startServerBlocking()
