local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(player)
	local function getState()
		return {}
	end

	return Badger.create({
		state = getState(),
		getFilter = function()
			return {}
		end,
		process = function(self, kind, event)
			-- process
		end,
		isComplete = function(self)
			return false
		end,
		reset = function(self)
			self.state = getState()
		end,
		getState = function(self)
			return Sift.Dictionary.copyDeep(self.state)
		end,
		save = function(self)
			return Sift.Dictionary.copyDeep(self.state)
		end,
		load = function(self, data)
			self.state = Sift.Dictionary.copyDeep(data)
		end,
	})
end
