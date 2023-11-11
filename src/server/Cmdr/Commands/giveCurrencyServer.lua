local ServerScriptService = game:GetService("ServerScriptService")

local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)

return function(_context, player, currencyType, amount)
	CurrencyService:AddCurrency(player, currencyType, amount)

	return "Success"
end
