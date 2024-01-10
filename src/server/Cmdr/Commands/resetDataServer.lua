local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Server.Services.DataService)

return function(_context, player)
	DataService:GetSaveFile(player):andThen(function(saveFile)
		for key, val in DataService.DefaultData do
			saveFile:Set(key, val)
		end
	end)

	player:Kick("Your data has been reset.")

	return "Success"
end
