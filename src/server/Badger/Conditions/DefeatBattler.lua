local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(player, battlerId, count)
	local function getState()
		return {
			victories = 0,
		}
	end

	return Badger.create({
		state = getState(),
		getFilter = function()
			return {
				BattleWon = true,
			}
		end,
		process = function(self, _, event)
			if event.Player ~= player then return end
			if event.BattlerId ~= battlerId then return end
			self.state.victories += 1
		end,
		isComplete = function(self)
			return self.state.victories >= count
		end,
		reset = function(self)
			self.state = getState()
		end,
		getState = function(self)
			return Sift.Dictionary.merge(self.state, {
				battlerId = battlerId,
				requirement = count,
			})
		end,
		save = function(self)
			return Sift.Dictionary.copyDeep(self.state)
		end,
		load = function(self, data)
			self.state = Sift.Dictionary.copyDeep(data)
		end,
	})
end
