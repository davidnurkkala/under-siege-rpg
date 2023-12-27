local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local ProductService = require(ServerScriptService.Server.Services.ProductService)
local Promise = require(ReplicatedStorage.Packages.Promise)

local MultiRollHelper = {}

function MultiRollHelper.Check(player: Player, count: number)
	if count < 2 then return Promise.resolve(true) end

	return ProductService:GetOwnsProduct(player, "MultiRoll"):andThen(function(owns)
		if owns then
			return true
		else
			return CurrencyService:ApplyPrice(player, { Premium = 1 }):andThen(function(success)
				return success
			end)
		end
	end)
end

return MultiRollHelper
