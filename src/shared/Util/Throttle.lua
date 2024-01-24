local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)

return function(cooldown: number)
	local last = 0

	return function(callback)
		local now = Timestamp()
		local since = now - last
		if since < cooldown then return end
		last = now

		callback()
	end
end
