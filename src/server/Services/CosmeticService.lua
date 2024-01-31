local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BaseDefs = require(ReplicatedStorage.Shared.Defs.BaseDefs)
local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)
local t = require(ReplicatedStorage.Packages.t)

local DefsByCategory = {
	Bases = BaseDefs,
}

local CosmeticService = {
	Priority = 0,
}

type CosmeticService = typeof(CosmeticService)

function CosmeticService.PrepareBlocking(self: CosmeticService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "CosmeticService")
	self.CosmeticsRemote = self.Comm:CreateProperty("Cosmetics", DataService.DefaultData.Cosmetics)

	self.Comm:BindFunction("Equip", function(player: Player, categoryName, id)
		if not t.string(categoryName) then return end
		if not t.string(id) then return end

		return self:EquipCosmetic(player, categoryName, id)
	end)

	Observers.observePlayer(function(player)
		return DataService:ObserveKey(player, "Cosmetics", function(cosmetics)
			self.CosmeticsRemote:SetFor(player, cosmetics)
		end)
	end)
end

function CosmeticService.OwnCosmetic(self: CosmeticService, player: Player, categoryName: string, id: string)
	local defs = DefsByCategory[categoryName]
	assert(defs ~= nil, `Invalid category {categoryName}`)

	local def = defs[id]
	assert(def ~= nil, `Invalid def {id} for category {categoryName}`)

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Cosmetics", function(cosmetics)
			return Sift.Dictionary.update(cosmetics, categoryName, function(category)
				return Sift.Dictionary.update(category, "Owned", function(owned)
					return Sift.Dictionary.set(owned, id, true)
				end)
			end)
		end)
	end)
end

function CosmeticService.EquipCosmetic(self: CosmeticService, player: Player, categoryName: string, id: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		if saveFile:Get("Cosmetics")[categoryName].Owned[id] ~= true then return end

		saveFile:Update("Cosmetics", function(cosmetics)
			return Sift.Dictionary.update(cosmetics, categoryName, function(category)
				return Sift.Dictionary.set(category, "Equipped", id)
			end)
		end)
	end)
end

function CosmeticService.GetEquipped(self: CosmeticService, player: Player, categoryName: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("Cosmetics")[categoryName].Equipped
	end)
end

return CosmeticService
