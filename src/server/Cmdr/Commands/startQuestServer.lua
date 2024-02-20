local ServerScriptService = game:GetService("ServerScriptService")

local QuestService = require(ServerScriptService.Server.Services.QuestService)

return function(_context, player, questId)
	QuestService:StartQuest(player, questId)

	return "Success"
end
