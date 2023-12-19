local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EffectPrestige = require(ReplicatedStorage.Shared.Effects.EffectPrestige)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local PrestigeHelper = require(ReplicatedStorage.Shared.Util.PrestigeHelper)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)
local WorldService = require(ServerScriptService.Server.Services.WorldService)
local t = require(ReplicatedStorage.Packages.t)

local PrestigeTypes = {
	Primary = true,
	Secondary = true,
}

local PrestigeService = {
	Priority = 0,
}

type PrestigeService = typeof(PrestigeService)

function PrestigeService.PrepareBlocking(self: PrestigeService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "PrestigeService")

	self.PointsRemote = self.Comm:CreateProperty("Points")

	Observers.observePlayer(function(player)
		return DataService:ObserveKey(player, "PrestigePoints", function(points)
			self.PointsRemote:SetFor(player, points)
		end)
	end)

	self.Comm:BindFunction("Prestige", function(player, prestigeType)
		if not t.string(prestigeType) then return end
		if not PrestigeTypes[prestigeType] then return end

		return self:Prestige(player, prestigeType):expect()
	end)
end

function PrestigeService.Start(self: PrestigeService)
	self.CurrencyService = require(ServerScriptService.Server.Services.CurrencyService) :: any
end

function PrestigeService.GetPrestigeCost(self: PrestigeService, player: Player)
	return self.CurrencyService:GetCurrency(player, "Prestige"):andThen(function(prestige)
		return PrestigeHelper.GetCost(prestige)
	end)
end

function PrestigeService.GetBoost(self: PrestigeService, player: Player, currencyType: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local points = saveFile:Get("PrestigePoints")[currencyType]
		if (points == nil) or (points == 0) then return 1 end

		return PrestigeHelper.GetBoost(points)
	end)
end

function PrestigeService.Prestige(self: PrestigeService, player: Player, prestigeType: string)
	return self:GetPrestigeCost(player)
		:andThen(function(cost)
			return self.CurrencyService:ApplyPrice(player, { Primary = cost })
		end)
		:andThen(function(success)
			if not success then return false end

			return EffectService:All(EffectPrestige({ Player = player }))
				:andThen(function()
					return Promise.all({
						self.CurrencyService:SetCurrency(player, "Primary", 0),
						self.CurrencyService:SetCurrency(player, "Secondary", 0),
						WorldService:ResetWorlds(player),
						WeaponService:ResetWeapons(player),
						self.CurrencyService:AddCurrency(player, "Prestige", 1),
					})
				end)
				:andThen(function()
					return DataService:GetSaveFile(player):andThen(function(saveFile)
						saveFile:Update("PrestigePoints", function(oldPoints)
							return Sift.Dictionary.update(oldPoints, prestigeType, function(number)
								return number + 1
							end)
						end)
					end)
				end)
				:andThenReturn(true)
		end)
end

return PrestigeService
