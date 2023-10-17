local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BattleService = require(ServerScriptService.Server.Services.BattleService)
local Battler = require(ServerScriptService.Server.Classes.Battler)
local PartPath = require(ReplicatedStorage.Shared.Classes.PartPath)
local PlayerBattler = require(ServerScriptService.Server.Classes.PlayerBattler)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local Battle = {}
Battle.__index = Battle

local BattleUpdater = Updater.new()

type Fieldable = {
	Position: number,
	Size: number,
	TeamId: string,
	IsActive: (Fieldable) -> boolean,
	Update: (Fieldable, number) -> (),
}

type BattlegroundModel = Model & {
	Spawns: Folder & {
		Left: BasePart,
		Right: BasePart,
	},
}

export type Battle = typeof(setmetatable(
	{} :: {
		Battlers: { any },
		Field: { [Fieldable]: boolean },
		Model: BattlegroundModel,
		Path: PartPath.PartPath,
	},
	Battle
))

function Battle.new(args: {
	Model: BattlegroundModel,
	Battlers: { Battler.Battler },
}): Battle
	local pathFolder = args.Model:FindFirstChild("Path")
	assert(pathFolder, "No path folder")

	local self: Battle = setmetatable({
		Battlers = args.Battlers,
		Model = args.Model,
		Field = {},
		Path = PartPath.new(pathFolder),
		Trove = Trove.new(),
		Destroyed = Signal.new(),
		Changed = Signal.new(),
	}, Battle)

	self.Model:PivotTo(CFrame.new(256, 0, 0))

	for _, entry in { { self.Battlers[1], self.Model.Spawns.Left }, { self.Battlers[2], self.Model.Spawns.Right } } do
		local battler, part = entry[1], entry[2]
		local base, char = battler.BaseModel, battler.CharModel

		base:PivotTo(part.CFrame)
		base.Parent = self.Model

		local cframe, size = char:GetBoundingBox()
		local dy = char:GetPivot().Y - (cframe.Y - size.Y / 2)
		char:PivotTo(base.Spawn.CFrame + Vector3.new(0, dy, 0))
		base.Spawn:Destroy()
	end

	self.Model.Spawns:Destroy()

	self.Model.Parent = workspace
	self.Trove:Add(self.Model)

	BattleUpdater:Add(self)
	self.Trove:Add(function()
		BattleUpdater:Remove(self)
	end)

	for _, battler in self.Battlers do
		self.Trove:Connect(battler.Destroyed, function()
			self:Destroy()
		end)
	end

	self.Trove:Add(function()
		for object in self.Field do
			object:Destroy()
		end

		for _, battler in self.Battlers do
			battler:Destroy()
		end
	end)

	return self
end

function Battle.fromPlayerVersusBattler(player: Player, battlerId: string, battlegroundName: string)
	-- TODO: get the castle that the player has

	return BattleService:Promise(player, function()
		return Promise.new(function(resolve, reject, onCancel)
			if BattleService:Get(player) then
				reject(`Player {player} already has a battle`)
				return
			end

			local char = player.Character or player.CharacterAdded:Wait()

			if onCancel() then return end

			while not char:IsDescendantOf(workspace) do
				task.wait()
			end

			if onCancel() then return end

			local root = char:FindFirstChild("HumanoidRootPart")
			if not root then
				reject("Bad character")
				return
			end

			resolve(char, root)
		end)
			:andThen(function(char, root)
				local leftBase = ReplicatedStorage.Assets.Models.Bases.Basic:Clone()
				root.Anchored = true

				local left = PlayerBattler.new(
					player,
					Battler.new({
						BaseModel = leftBase,
						CharModel = char,
						Direction = 1,
						Position = 0,
						HealthMax = 100,
					})
				)

				left.Battler.Destroyed:Connect(function()
					root.Anchored = false
				end)

				local rightBase = ReplicatedStorage.Assets.Models.Bases.Basic:Clone()

				local rightChar = ReplicatedStorage.Assets.Models.Battlers[battlerId]:Clone()
				rightChar.Parent = workspace

				local right = Battler.new({
					BaseModel = rightBase,
					CharModel = rightChar,
					Direction = -1,
					Position = 1,
					HealthMax = 100,
				})

				right.Destroyed:Connect(function()
					rightChar:Destroy()
				end)

				local battleground = ReplicatedStorage.Assets.Models.Battlegrounds[battlegroundName]:Clone()

				return Battle.new({
					Battlers = { left.Battler, right },
					Model = battleground,
				})
			end)
			:tap(function(battle)
				BattleService:Add(player, battle)
				battle.Destroyed:Connect(function()
					BattleService:Remove(player)
				end)
			end)
	end)
end

function Battle.GetStatus(self: Battle)
	return {
		Battlers = Sift.Array.map(self.Battlers, function(battler)
			return battler:GetStatus()
		end),
	}
end

function Battle.Observe(self: Battle, callback)
	local connection = self.Changed:Connect(callback)
	callback(self:GetStatus())
	return connection
end

function Battle.Add(self: Battle, object: Fieldable)
	if self.Field[object] then return end

	self.Field[object] = true
end

function Battle.Remove(self: Battle, object: Fieldable)
	if not self.Field[object] then return end

	self.Field[object] = nil
end

function Battle.Update(self: Battle, dt: number)
	for object in self.Field do
		object:Update(dt)

		if not object:IsActive() then
			object:Destroy()
			self:Remove(object)
		end
	end

	local victor = self:GetVictor()
	if victor then self:Destroy() end
end

function Battle.GetVictor(self: Battle): Battler.Battler?
	local active = nil
	for _, battler in self.Battlers do
		if battler:IsActive() then
			if active then
				return nil
			else
				active = battler
			end
		end
	end
	return active
end

function Battle.Destroy(self: Battle)
	self.Trove:Clean()
	self.Destroyed:Fire()
end

return Battle
