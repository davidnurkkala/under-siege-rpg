local ServerScriptService = game:GetService("ServerScriptService")

local BattleHelper = require(ServerScriptService.Server.Util.BattleHelper)

return function(context, battlerId)
	BattleHelper.FadeToBattle(context.Executor, battlerId)

	return "Success"
end
