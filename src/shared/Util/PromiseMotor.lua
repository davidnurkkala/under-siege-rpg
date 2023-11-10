local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

return function(motor, goal, predicate)
	return Promise.new(function(resolve, _, onCancel)
		motor:setGoal(goal)

		local connection
		connection = motor:onStep(function(...)
			if predicate(...) then
				resolve()
				connection:disconnect()
			end
		end)

		onCancel(function()
			connection:disconnect()
		end)
	end)
end
