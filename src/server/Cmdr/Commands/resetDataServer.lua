local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Server.Services.DataService)

return function(_context, player)
	DataService:DeleteSaveFile(player)

	return "Success"
end
