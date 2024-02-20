local ServerScriptService = game:GetService("ServerScriptService")

local AdvanceQuest = require(ServerScriptService.Server.Badger.Conditions.AdvanceQuest)
local DeckService = require(ServerScriptService.Server.Services.DeckService)
local DefeatBattler = require(ServerScriptService.Server.Badger.Conditions.DefeatBattler)
local DialogueHelper = require(ServerScriptService.Server.Util.DialogueHelper)
local QuestHelper = require(ServerScriptService.Server.Util.QuestHelper)
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
			{
				Name = "DefeatThePeasant",
				Condition = DefeatBattler(player, "Peasant", 1):described(function(self)
					local state = self:getState()
					return `Defeat the Peasant\n{state.victories} / {state.requirement} wins`
				end):targeting(function()
					return DialogueHelper.GetPromptModel("PeasantJohnSower")
				end),
			},
			{
				Name = "TellGuildmasterDefeatedPeasant",
				Condition = AdvanceQuest(player, script.Name)
					:described("Tell the mercenary guildmaster about your victory.")
					:targeting(function()
						return DialogueHelper.GetPromptModel("GuildmasterKutz")
					end)
					:whenCompleted(function()
						DeckService:AddCard(player, "Spearman")
					end),
			},
			{
				Name = "DefeatABandit",
				Condition = DefeatBattler(player, "BanditCaptain", 1):described(function(self)
					local state = self:getState()
					return `Defeat a Bandit\n{state.victories} / {state.requirement} wins`
				end):targeting(function()
					return QuestHelper.GetQuestTarget(script.Name, "Bandit")
				end),
			},
			{
				Name = "TellGuildmasterDefeatedBandit",
				Condition = AdvanceQuest(player, script.Name)
					:described("Tell the mercenary guildmaster about your victory")
					:targeting(function()
						return DialogueHelper.GetPromptModel("GuildmasterKutz")
					end)
					:whenCompleted(function()
						DeckService:AddCard(player, "Archer")
					end),
			},
			{
				Name = "DefeatTheGuildmaster",
				Condition = DefeatBattler(player, "GuildmasterKutz", 1)
					:described(function(self)
						local state = self:getState()
						return `Defeat the guildmaster\n{state.victories} / {state.requirement} wins`
					end)
					:targeting(function()
						return DialogueHelper.GetPromptModel("GuildmasterKutz")
					end)
					:whenCompleted(function()
						DeckService:AddCard(player, "Recruit")
					end),
			},
		})
	end,
	OnCompleted = function() end,
}
