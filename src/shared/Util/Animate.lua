local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.Packages.Promise)

return function(duration, callback)
	local timer = 0

	return Promise.resolve():andThenCall(callback, 0):andThenCall(Promise.fromEvent, RunService.Heartbeat, function(dt)
		timer = math.min(duration, timer + dt)
		callback(timer / duration)
		return timer == duration
	end)
end
