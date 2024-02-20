local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local DataService = require(ServerScriptService.Server.Services.DataService)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PlayerListLeaderboardService = {
	Priority = 0,
}

type PlayerListLeaderboardService = typeof(PlayerListLeaderboardService)

function PlayerListLeaderboardService.PrepareBlocking(_self: PlayerListLeaderboardService)
	Observers.observePlayer(function(player)
		local trove = Trove.new()

		local folder = Instance.new("Folder")
		folder.Name = "leaderstats"
		folder.Parent = player

		local valueByCurrencyType = {}

		for _, currencyType in { "Prestige" } do
			local val = Instance.new("IntValue")
			val.Name = CurrencyDefs[currencyType].Name
			val.Parent = folder
			valueByCurrencyType[currencyType] = val
		end

		trove:Add(DataService:ObserveKey(player, "Currency", function(currency)
			for currencyType, amount in currency do
				local val = valueByCurrencyType[currencyType]
				if val then val.Value = amount end
			end
		end))

		return function()
			trove:Clean()
		end
	end)
end

return PlayerListLeaderboardService
