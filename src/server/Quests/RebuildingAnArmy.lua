local ServerScriptService = game:GetService("ServerScriptService")

local AdvanceQuest = require(ServerScriptService.Server.Badger.Conditions.AdvanceQuest)
local DialogueHelper = require(ServerScriptService.Server.Util.DialogueHelper)
local StagedQuest = require(ServerScriptService.Server.Badger.Conditions.StagedQuest)

return {
	Name = "Rebuilding an Army",
	Summary = "These peasants -- while loyal -- aren't soldiers. I need real troops if I want to reclaim my kingdom.",
	Condition = function(player)
		return StagedQuest(player, script.Name, {
			{
				Name = "SpeakToGuildmaster",
				Condition = AdvanceQuest(player, script.Name):described("Speak to the mercenary guildmaster."):targeting(function()
					return DialogueHelper.GetPromptModel("GuildmasterKutz")
				end),
			},
		})
	end,
	OnCompleted = function() end,
}
