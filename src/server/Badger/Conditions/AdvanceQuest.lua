local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(player, questId)
	local function getState()
		return {
			complete = false,
		}
	end

	return Badger.create({
		state = getState(),
		getFilter = function()
			return { QuestAdvanced = true }
		end,
		process = function(self, _, event)
			if event.Player ~= player then return end
			if event.QuestId ~= questId then return end
			self.state.complete = true
		end,
		isComplete = function(self)
			return self.state.complete
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
