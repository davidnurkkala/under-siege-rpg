local ServerScriptService = game:GetService("ServerScriptService")

local DialogueService = require(ServerScriptService.Server.Services.DialogueService)

return function(context)
	DialogueService:StartDialogue(context.Executor, "OpeningCutscene")

	return "Success"
end
