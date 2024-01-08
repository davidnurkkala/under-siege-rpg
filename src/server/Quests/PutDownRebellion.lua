local ServerScriptService = game:GetService("ServerScriptService")

local DefeatBattler = require(ServerScriptService.Server.Badger.Conditions.DefeatBattler)

return function(player)
	return DefeatBattler(player)
end
