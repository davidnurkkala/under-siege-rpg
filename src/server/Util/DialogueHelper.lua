local ServerScriptService = game:GetService("ServerScriptService")

local DialogueHelper = {}

function DialogueHelper.StartDialogue(...)
	(require(ServerScriptService.Server.Services.DialogueService) :: any):StartDialogue(...)
end

return DialogueHelper
