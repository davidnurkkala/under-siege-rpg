local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Server.Services.DataService)

return function(_context, player)
	DataService:GetSaveFile(player):andThen(function(saveFile)
		player:Kick("Your quest data is being reset.")
		saveFile:Set("QuestData", {})
	end)

	return "Success"
end
