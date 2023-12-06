local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BoostHelper = require(ReplicatedStorage.Shared.Util.BoostHelper)
local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)
local t = require(ReplicatedStorage.Packages.t)

local BoostService = {
	Priority = 0,
}

type BoostService = typeof(BoostService)

function BoostService.PrepareBlocking(self: BoostService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "BoostService")

	self.BoostsRemote = self.Comm:CreateProperty("Boosts")

	Observers.observePlayer(function(player)
		return DataService:ObserveKey(player, "Boosts", function(boosts)
			self.BoostsRemote:SetFor(player, boosts)
		end)
	end)
end

function BoostService.Start(self: BoostService)
	while true do
		for _, player in Players:GetPlayers() do
			DataService:GetSaveFile(player):andThen(function(saveFile)
				saveFile:Update("Boosts", function(oldBoosts)
					return Sift.Array.map(oldBoosts, function(boost)
						local newBoost = Sift.Dictionary.set(boost, "Time", boost.Time - 1)
						if newBoost.Time <= 0 then return nil end
						return newBoost
					end)
				end)
			end)
		end

		task.wait(1)
	end
end

function BoostService.GetMultiplier(self: BoostService, player: Player, predicate)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return BoostHelper.GetMultiplier(saveFile:Get("Boosts"), predicate)
	end)
end

function BoostService.AddBoost(self: BoostService, player: Player, boost: any)
	assert(typeof(boost) == "table", `Boost must be a table`)
	assert(boost.Type ~= nil, `Boost must have a type`)
	assert(t.numberPositive(boost.Time), `All boosts must have a positive time`)
	assert(t.number(boost.Multiplier) and boost.Multiplier > 1, `All boosts must have a multiplier that is greater than 1`)

	if boost.Type == "Currency" then
		assert(boost.CurrencyType, `Currency boosts must have a currency type`)
		assert(Sift.Set.has({ Primary = true, Secondary = true }, boost.CurrencyType), `Currency boosts can only be for Primary or Secondary currency`)
	elseif boost.Type ~= "Damage" then
		error(`Unimplemented boost type {boost.Type}`)
	end

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Boosts", function(oldBoosts)
			local index = Sift.Array.findWhere(oldBoosts, function(oldBoost)
				return Sift.Dictionary.equals(Sift.Dictionary.removeKeys(oldBoost, "Time"), Sift.Dictionary.removeKeys(boost, "Time"))
			end)

			if index then
				return Sift.Array.update(oldBoosts, index, function(oldBoost)
					return Sift.Dictionary.set(oldBoost, "Time", oldBoost.Time + boost.Time)
				end)
			else
				return Sift.Array.append(oldBoosts, boost)
			end
		end)
	end)
end

return BoostService
