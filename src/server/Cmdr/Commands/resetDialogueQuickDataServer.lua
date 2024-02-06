local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Server.Services.DataService)

return function(_context, player)
	DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Set("DialogueQuickData", nil)
	end)

	return "Success"
end
