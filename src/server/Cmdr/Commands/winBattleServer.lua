local ServerScriptService = game:GetService("ServerScriptService")

local BattleService = require(ServerScriptService.Server.Services.BattleService)

return function(context)
	local battle = BattleService:Get(context.Executor)
	if not battle then return end

	for _, battler in battle.Battlers do
		if battler.CharModel ~= context.Executor.Character then battler.Health:Set(-999999999) end
	end

	return "Success"
end
