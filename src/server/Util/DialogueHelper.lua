local ServerScriptService = game:GetService("ServerScriptService")

local ComponentService = require(ServerScriptService.Server.Services.ComponentService)

local DialogueHelper = {}

function DialogueHelper.StartDialogue(...)
	(require(ServerScriptService.Server.Services.DialogueService) :: any):StartDialogue(...)
end

function DialogueHelper.GetPromptModel(dialogueId)
	for _, dialoguePrompt in ComponentService:GetComponentsByName("DialoguePrompt") do
		if dialoguePrompt.Id == dialogueId then return dialoguePrompt.Model end
	end
	return nil
end

return DialogueHelper
