local ServerScriptService = game:GetService("ServerScriptService")

local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local WorldService = require(ServerScriptService.Server.Services.WorldService)

local function getDialogueService()
	return require(ServerScriptService.Server.Services.DialogueService) :: any
end

local ConsequenceHelper = {}

function ConsequenceHelper.Mugged(player: Player, coinPercent: number, getText: (number) -> ())
	return CurrencyService:GetCurrency(player, "Coins"):andThen(function(value)
		local taken = math.floor(value * coinPercent)
		return CurrencyService:ApplyPrice(player, { Coins = taken })
			:andThen(function()
				return WorldService:GetCurrentWorld(player)
			end)
			:andThen(function(worldId)
				return WorldService:TeleportToWorld(player, worldId, function()
					getDialogueService():OneOff(player, { Text = getText(taken) })
				end)
			end)
	end)
end

return ConsequenceHelper
