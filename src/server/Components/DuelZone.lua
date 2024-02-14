local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Server.Services.DataService)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local DuelZoneUpdater = Updater.new()
local Height = 16

local DuelZone = {}
DuelZone.__index = DuelZone

export type DuelZone = typeof(setmetatable(
	{} :: {
		Trove: any,
		Root: Part,
		Players: Property.Property,
		HalfSize: Vector3,
	},
	DuelZone
))

function DuelZone.new(part: Part): DuelZone
	assert(part.Shape == Enum.PartType.Block, "Part must be a block for now")

	local self: DuelZone = setmetatable({
		Root = part,
		HalfSize = part.Size / 2,
		Trove = Trove.new(),
		Players = Property.new({}, Sift.Dictionary.equals),
	}, DuelZone)

	self.Players:Observe(function(players: { Player })
		local trove = Trove.new()

		for player in players do
			player:AddTag("DuelingPlayer")
			trove:Add(function()
				player:RemoveTag("DuelingPlayer")
			end)

			trove:AddPromise(DataService:GetSaveFile(player)):andThen(function(saveFile)
				local duelWins = saveFile:Get("DuelWins") or 0

				local char = player.Character
				if not char then return end

				char:AddTag("OverheadLabeled")
				char:SetAttribute("OverheadLabel", `Duel wins: {duelWins}`)

				trove:Add(function()
					char:RemoveTag("OverheadLabeled")
					char:SetAttribute("OverheadLabel", nil)
				end)
			end)
		end

		return function()
			trove:Clean()
		end
	end)

	DuelZoneUpdater:Add(self)
	self.Trove:Add(function()
		DuelZoneUpdater:Remove(self)
	end)

	self.Trove:Add(self.Players)

	return self
end

function DuelZone.Update(self: DuelZone)
	self.Players:Set(Sift.Array.toSet(Sift.Array.filter(Players:GetPlayers(), function(player)
		local char = player.Character
		if not char then return false end
		local root = char.PrimaryPart
		if not root then return false end

		local delta = self.Root.CFrame:PointToObjectSpace(root.Position)

		return delta.Y > 0
			and delta.Y < Height
			and delta.X > -self.HalfSize.X
			and delta.X < self.HalfSize.X
			and delta.Z < self.HalfSize.Z
			and delta.Z > -self.HalfSize.Z
	end)))
end

function DuelZone.Destroy(self: DuelZone)
	self.Trove:Clean()
end

return DuelZone
