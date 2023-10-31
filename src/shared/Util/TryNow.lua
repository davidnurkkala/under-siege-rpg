local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

return function(callback, default)
	return Promise.try(callback)
		:catch(function()
			return default
		end)
		:now()
		:catch(function()
			return default
		end)
		:expect()
end
