local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(player, count)
	local function getState()
		return {
			attacks = 0,
		}
	end

	return Badger.create({
		state = getState(),
		getFilter = function()
			return {
				UsedInBattleAttack = true,
			}
		end,
		process = function(self, _, event)
			if event.Player ~= player then return end
			self.state.attacks += 1
		end,
		isComplete = function(self)
			return self.state.attacks >= count
		end,
		reset = function(self)
			self.state = getState()
		end,
		getState = function(self)
			return Sift.Dictionary.merge(self.state, {
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
