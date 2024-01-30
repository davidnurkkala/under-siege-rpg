local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BoostService = require(ServerScriptService.Server.Services.BoostService)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DeckService = require(ServerScriptService.Server.Services.DeckService)
local ProductHelper = require(ReplicatedStorage.Shared.Util.ProductHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)
local WeightTable = require(ReplicatedStorage.Shared.Classes.WeightTable)

local Rand = Random.new()

local RewardHelper = {}

function RewardHelper.GiveReward(player: Player, reward: any)
	assert(typeof(reward) == "table", `Expected reward to be a table.`)

	if reward.Type == "Currency" then
		return CurrencyService:GetBoosted(player, reward.CurrencyType, reward.Amount):andThen(function(amount)
			return CurrencyService:AddCurrency(player, reward.CurrencyType, amount):andThenReturn(Sift.Dictionary.set(reward, "Amount", amount))
		end)
	elseif reward.Type == "Card" then
		return DeckService:HasCard(player, reward.CardId):andThen(function(hasCard)
			if hasCard then return end

			return DeckService:AddCard(player, reward.CardId):andThenReturn(reward)
		end)
	elseif reward.Type == "Boost" then
		return BoostService:AddBoost(player, reward.Boost):andThenReturn(reward)
	elseif reward.Type == "Weapon" then
		return WeaponService:OwnWeapon(player, reward.WeaponId):andThenReturn(reward)
	else
		error(`Unrecognized reward type {reward.Type}`)
	end
end

function RewardHelper.ProcessChanceTable(player: Player, chanceTable: { { Chance: number, Result: any } })
	return Sift.Array.map(
		Sift.Array.filter(chanceTable, function(entry)
			local chance = entry.Chance

			if ProductHelper.IsVip(player) then
				chance *= 1.25
			end

			return Rand:NextNumber() <= chance
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
