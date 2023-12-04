local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerFade = require(ServerScriptService.Server.Util.ServerFade)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WorldDefs = require(ReplicatedStorage.Shared.Defs.WorldDefs)
local t = require(ReplicatedStorage.Packages.t)

local WorldService = {
	Priority = 0,
}

type WorldService = typeof(WorldService)

function WorldService.PrepareBlocking(self: WorldService)
	local ocean = Instance.new("Folder")
	ocean.Name = "Ocean"
	ocean.Parent = workspace

	local oceanRadius = 2
	local oceanCellSize = 2048
	for x = -oceanRadius, oceanRadius do
		for z = -oceanRadius, oceanRadius do
			local oceanCell = ReplicatedStorage.Assets.Models.Ocean:Clone()
			oceanCell:PivotTo(CFrame.new(x * oceanCellSize, -20, z * oceanCellSize))
			oceanCell.Parent = ocean
		end
	end

	self.WorldModels = Sift.Dictionary.map(WorldDefs, function(def, id)
		local model = def.Model:Clone()
		model:PivotTo(CFrame.new(def.Position))
		model.Parent = workspace

		return model, id
	end)

	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "WorldService")

	self.WorldsRemote = self.Comm:CreateProperty("Worlds", {})

	Observers.observePlayer(function(player)
		return DataService:ObserveKey(player, "Worlds", function(worlds)
			self.WorldsRemote:SetFor(player, worlds)
		end)
	end)

	self.Comm:CreateSignal("WorldTeleportRequested"):Connect(function(player: Player, worldId: string)
		if not t.string(worldId) then return end

		return self:TeleportToWorld(player, worldId):expect()
	end)

	self.Comm:CreateSignal("WorldPurchaseRequested"):Connect(function(player: Player, worldId: string)
		if not t.string(worldId) then return end

		return self:PurchaseWorld(player, worldId):expect()
	end)
end

function WorldService.PurchaseWorld(self: WorldService, player: Player, worldId: string)
	local def = WorldDefs[worldId]
	assert(def, `No def for id {worldId}`)

	local price = {
		Secondary = def.Price,
	}

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		print("has wordl?")
		if Sift.Set.has(saveFile:Get("Worlds"), worldId) then return end
		print("no!!")

		return CurrencyService:ApplyPrice(player, price):andThen(function(success)
			print("scucc?")
			if not success then return end
			print("haz mun")

			saveFile:Update("Worlds", function(oldWorlds)
				print("updoot")
				return Sift.Set.add(oldWorlds, worldId)
			end)
		end)
	end)
end

function WorldService.TeleportToWorld(self: WorldService, player: Player, worldId: string)
	local def = WorldDefs[worldId]
	assert(def, `No def for id {worldId}`)

	local model = self.WorldModels[worldId]
	local char = player.Character
	if (model == nil) or (char == nil) then return end

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		if not saveFile:Get("Worlds")[worldId] then return end

		return ServerFade(player, nil, function()
			char:PivotTo(model:GetPivot() + Vector3.new(0, 4, 0))
		end)
	end)
end

return WorldService
