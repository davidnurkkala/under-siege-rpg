local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BattleService = require(ServerScriptService.Server.Services.BattleService)
local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EffectPrestige = require(ReplicatedStorage.Shared.Effects.EffectPrestige)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
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
	if BattleService:Get(player) then return Promise.resolve(false) end
	if player:GetAttribute("IsPrestiging") then return Promise.resolve(false) end

	return self:GetPrestigeCost(player)
		:andThen(function(cost)
			return self.CurrencyService:ApplyPrice(player, { Primary = cost })
		end)
		:andThen(function(success)
			if not success then return false end

			player:SetAttribute("IsPrestiging", true)
			return EffectService:All(EffectPrestige({ Player = player }))
				:andThen(function()
					return WorldService:ResetWorlds(player, function()
						self.CurrencyService
							:SetCurrency(player, "Primary", 0)
							:andThen(function()
								local session = LobbySessions.Get(player)
								if session then session:CancelAttacks() end

								return self.CurrencyService:SetCurrency(player, "Secondary", 0)
							end)
							:andThen(function()
								return WeaponService:ResetWeapons(player)
							end)
							:andThen(function()
								self.CurrencyService:AddCurrency(player, "Prestige", 1)
							end)
							:expect()
					end)
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
				:finally(function()
					player:SetAttribute("IsPrestiging", false)
				end)
		end)
end

return PrestigeService
