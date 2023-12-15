local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(player, gachaId, count)
	local function getState()
		return {
			rolls = 0,
		}
	end

	return Badger.create({
		state = getState(),
		getFilter = function()
			return {
				PetGachaRolled = true,
			}
		end,
		process = function(self, _, event)
			if event.GachaId ~= gachaId then return end
			if event.Player ~= player then return end

			self.state.rolls += 1
		end,
		isComplete = function(self)
			return self.state.rolls >= count
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
