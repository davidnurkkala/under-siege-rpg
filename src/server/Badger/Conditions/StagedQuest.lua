local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AdvanceQuest = require(ServerScriptService.Server.Badger.Conditions.AdvanceQuest)
local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(player, questId, stages: { { Name: string, Condition: Badger.Condition } })
	stages = Sift.Array.prepend(stages, {
		Name = "Unstarted",
		Condition = AdvanceQuest(player, questId),
	})

	return Badger.sequence(Sift.Array.map(stages, function(stage)
		return stage.Condition:named(stage.Name)
	end))
end
