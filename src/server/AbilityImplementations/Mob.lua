local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Range = require(ReplicatedStorage.Shared.Util.Range)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(def, level, battler, battle)
	return Promise.all(Sift.Array.map(Range(2), function(number)
		return Promise.delay(number - 1):andThen(function()
			battle:PlayCard(battler, "Peasant", CardHelper.LevelToCount(level))
		end)
	end))
end
