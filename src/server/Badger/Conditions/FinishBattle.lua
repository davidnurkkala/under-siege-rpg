local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local DefeatBattler = require(ServerScriptService.Server.Badger.Conditions.DefeatBattler)
local Sift = require(ReplicatedStorage.Packages.Sift)

local function startBattle(player, battlerId)
	local function getState()
		return {
			complete = false,
		}
	end

	return Badger.create({
		state = getState(),
		getFilter = function()
			return { BattleStarted = true }
		end,
		process = function(self, _, event)
			if event.Player ~= player then return end
			if event.BattlerId ~= battlerId then return end
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

return function(player, battlerId)
	return Badger.sequence({
		startBattle(player, battlerId),
		DefeatBattler(player, battlerId, 1),
	})
end
