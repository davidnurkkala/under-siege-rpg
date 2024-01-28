local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BoostService = require(ServerScriptService.Server.Services.BoostService)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DeckService = require(ServerScriptService.Server.Services.DeckService)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WeightTable = require(ReplicatedStorage.Shared.Classes.WeightTable)

local Rand = Random.new()

local RewardHelper = {}

function RewardHelper.GiveReward(player: Player, reward: any)
	assert(typeof(reward) == "table", `Expected reward to be a table.`)

	if reward.Type == "Currency" then
		return CurrencyService:GetBoosted(player, reward.CurrencyType, reward.Amount):andThen(function(amount)
			return CurrencyService:AddCurrency(player, reward.CurrencyType, amount)
		end)
	elseif reward.Type == "Card" then
		return DeckService:HasCard(player, reward.CardId):andThen(function(hasCard)
			if hasCard then return end

			return DeckService:AddCard(player, reward.CardId)
		end)
	elseif reward.Type == "Boost" then
		return BoostService:AddBoost(player, reward.Boost)
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

function RewardHelper.ProcessChanceTable(_player: Player, chanceTable: { { Chance: number, Result: any } })
	return Sift.Array.map(
		Sift.Array.filter(chanceTable, function(entry)
			return Rand:NextNumber() <= entry.Chance
		end),
		function(entry)
			return Sift.Dictionary.map(entry.Result, function(value)
				if WeightTable.Is(value) then
					return value:Roll()
				else
					return value
				end
			end)
		end
	)
end

return RewardHelper
