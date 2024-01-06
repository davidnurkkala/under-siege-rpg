local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local LightingService = require(ServerScriptService.Server.Services.LightingService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local ServerFade = require(ServerScriptService.Server.Util.ServerFade)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WorldDefs = require(ReplicatedStorage.Shared.Defs.WorldDefs)
local t = require(ReplicatedStorage.Packages.t)

local WorldService = {
	Priority = 0,
}

type WorldService = typeof(WorldService)

function WorldService.PrepareBlocking(self: WorldService)
	self:BuildOcean()

	self.WorldModels = Sift.Dictionary.map(WorldDefs, function(def, id)
		local model = def.Model:Clone()
		model:PivotTo(CFrame.new(def.Position))

		for _, object in model:GetDescendants() do
			if object:IsA("Humanoid") then object.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
		end

		model.Parent = workspace.Worlds

		return model, id
	end)

	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "WorldService")

	self.WorldsRemote = self.Comm:CreateProperty("Worlds", {})
	local worldCurrentRemote = self.Comm:CreateProperty("WorldCurrent", "World1")

	Observers.observePlayer(function(player)
		local trove = Trove.new()

		trove:Add(DataService:ObserveKey(player, "Worlds", function(worlds)
			self.WorldsRemote:SetFor(player, worlds)
		end))

		trove:Add(DataService:ObserveKey(player, "WorldCurrent", function(worldCurrent)
			worldCurrentRemote:SetFor(player, worldCurrent)
		end))

		return function()
			trove:Clean()
		end
	end)

	Observers.observePlayer(function(player)
		local promise = Promise.new(function(resolve, _, onCancel)
			repeat
				local success = (player.Character ~= nil)
					and (player.Character:IsDescendantOf(workspace))
					and (player.Character.PrimaryPart ~= nil)
					and (player.Character.PrimaryPart:IsDescendantOf(workspace))

				if not success then
					task.wait()
					if onCancel() then return end
				end
			until success

			resolve()
		end)
			:andThen(function()
				return DataService:GetSaveFile(player)
			end)
			:andThen(function(saveFile)
				return self:TeleportToWorld(player, saveFile:Get("WorldCurrent"))
			end)

		return function()
			promise:cancel()
		end
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

function WorldService.ResetWorlds(self: WorldService, player: Player, callback)
	return self:TeleportToWorld(player, DataService.DefaultData.WorldCurrent, callback)
		:andThen(function()
			return DataService:GetSaveFile(player)
		end)
		:andThen(function(saveFile)
			saveFile:Set("Worlds", DataService.DefaultData.Worlds)
		end)
end

function WorldService.PurchaseWorld(self: WorldService, player: Player, worldId: string)
	local def = WorldDefs[worldId]
	assert(def, `No def for id {worldId}`)

	local price = {
		Secondary = def.Price,
	}

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		if Sift.Set.has(saveFile:Get("Worlds"), worldId) then return end

		return CurrencyService:ApplyPrice(player, price):andThen(function(success)
			if not success then return end

			saveFile:Update("Worlds", function(oldWorlds)
				return Sift.Set.add(oldWorlds, worldId)
			end)

			return self:TeleportToWorld(player, worldId)
		end)
	end)
end

function WorldService.BuildOcean(self: WorldService)
	local ocean = Instance.new("Folder")
	ocean.Name = "Ocean"
	ocean.Parent = workspace

	local cooldowns = {}
	local function onTouched(part)
		local char = part.Parent
		if not char then return end
		local player = Players:GetPlayerFromCharacter(char)
		if not player then return end
		if cooldowns[player] then return end

		cooldowns[player] = true
		self:TeleportToWorld(player, "World1"):andThenCall(Promise.delay, 1):finally(function()
			cooldowns[player] = nil
		end)
	end

	local oceanRadius = 2
	local oceanCellSize = 2048
	for x = -oceanRadius, oceanRadius do
		for z = -oceanRadius, oceanRadius do
			local oceanCell = ReplicatedStorage.Assets.Models.Ocean:Clone()
			oceanCell:PivotTo(CFrame.new(x * oceanCellSize, -20, z * oceanCellSize))
			oceanCell.Parent = ocean

			for _, object in oceanCell:GetDescendants() do
				if object:IsA("BasePart") and object.CanTouch then object.Touched:Connect(onTouched) end
			end
		end
	end
end

function WorldService.TeleportToWorld(self: WorldService, player: Player, worldId: string, callback)
	local def = WorldDefs[worldId]
	assert(def, `No def for id {worldId}`)

	local model = self.WorldModels[worldId]
	local char = player.Character
	if (model == nil) or (char == nil) then return end

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		if not saveFile:Get("Worlds")[worldId] then return end

		return ServerFade(player, nil, function()
			if callback then callback() end
			saveFile:Set("WorldCurrent", worldId)
			LightingService.LightingChangeRequested:Fire(player, def.LightingName)
			char:PivotTo(model:GetPivot() + Vector3.new(0, 4, 0))
		end)
	end)
end

function WorldService.GetCurrentWorld(self: WorldService, player: Player)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("WorldCurrent")
	end)
end

return WorldService
