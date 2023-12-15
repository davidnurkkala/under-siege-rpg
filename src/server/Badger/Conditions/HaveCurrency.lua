local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)

return function(player, currencyType, amount)
	return Badger.create({
		getFilter = function()
			return {
				CurrencyAdded = true,
			}
		end,
		getState = function()
			return {
				current = CurrencyService:GetCurrency(player, currencyType):expect(),
				required = amount,
			}
		end,
		isComplete = function()
			return CurrencyService:HasCurrency(player, currencyType, amount):expect()
		end,
	})
end
