local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BattleService = require(ServerScriptService.Server.Services.BattleService)
local BattleSession = require(ServerScriptService.Server.Classes.BattleSession)
local Battler = require(ServerScriptService.Server.Classes.Battler)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local Goon = require(ServerScriptService.Server.Classes.Goon)
local PartPath = require(ReplicatedStorage.Shared.Classes.PartPath)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local Battle = {}
Battle.__index = Battle

local ChooseDuration = 4
local RoundDuration = ChooseDuration + 1

local BattleUpdater = Updater.new()

type Fieldable = {
	Position: number,
	Size: number,
	TeamId: string,
	IsActive: (Fieldable) -> boolean,
	Update: (Fieldable, number) -> (),
}

type BattleTarget = {
	Position: number,
	Size: number,
	TeamId: string,
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
		RoundCooldown: any,
		State: "Active" | "Ended",
	},
	Battle
))

function Battle.new(args: {
	Model: BattlegroundModel,
	Battlers: { Battler.Battler },
}): Battle
	local trove = Trove.new()

	local pathFolder = args.Model:FindFirstChild("Path")
	assert(pathFolder, "No path folder")

	trove:Add(BattleService:ReserveSlot(function(position)
		args.Model:PivotTo(CFrame.new(position))
	end))

	local self: Battle = setmetatable({
		Battlers = args.Battlers,
		Model = args.Model,
		Field = {},
		Path = PartPath.new(pathFolder),
		Trove = trove,
		Destroyed = Signal.new(),
		Ended = Signal.new(),
		Changed = Signal.new(),
		State = "Active",
	}, Battle)

	for _, entry in { { self.Battlers[1], self.Model.Spawns.Left }, { self.Battlers[2], self.Model.Spawns.Right } } do
		local battler, part = entry[1], entry[2]
		local base, char = battler.BaseModel, battler.CharModel

		base:PivotTo(part.CFrame)
		base.Parent = self.Model

		local cframe, size = char:GetBoundingBox()
		local dy = char:GetPivot().Y - (cframe.Y - size.Y / 2)
		char:PivotTo(base.Spawn.CFrame + Vector3.new(0, dy, 0))
		base.Spawn:Destroy()

		battler:Observe(function()
			self.Changed:Fire(self:GetStatus())
		end)
	end

	self.Model.Spawns:Destroy()

	self.RoundCooldown = Cooldown.new(RoundDuration)

	self.Model.Parent = workspace
	self.Trove:Add(self.Model)

	BattleUpdater:Add(self)
	self.Trove:Add(function()
		BattleUpdater:Remove(self)
	end)

	self.Trove:Add(function()
		for object in self.Field do
			object:Destroy()
		end

		for _, battler in self.Battlers do
			battler:Destroy()
		end
	end)

	for _, battler in self.Battlers do
		battler:SetBattle(self)
	end

	return self
end

function Battle.fromPlayerVersusBattler(player: Player, battlerId: string, battlegroundName: string)
	return BattleService:Promise(player, function()
		return Promise.new(function(resolve, reject)
			if BattleService:Get(player) then
				reject(`Player {player} already has a battle`)
				return
			end

			resolve(BattleSession.promised(player, 0, 1))
		end)
			:andThen(function(battleSession)
				local battleground = ReplicatedStorage.Assets.Models.Battlegrounds[battlegroundName]:Clone()

				return Battle.new({
					Battlers = { battleSession.Battler, Battler.fromBattlerId(battlerId, 1, -1) },
					Model = battleground,
				})
			end)
			:tap(function(battle)
				BattleService:Add(player, battle)
				battle.Destroyed:Connect(function()
					BattleService:Remove(player)

					local def = BattlerDefs[battlerId]
					CurrencyService:AddCurrency(player, "Secondary", def.Reward)
				end)
			end)
	end)
end

function Battle.GetStatus(self: Battle)
	return {
		Model = self.Model,
		Battlers = Sift.Array.map(self.Battlers, function(battler: Battler.Battler)
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

function Battle.PlayCard(self: Battle, battler: Battler.Battler, cardId: string, cardLevel: number)
	local card = CardDefs[cardId]
	assert(card, `No card for id {cardId}`)

	if card.Type == "Goon" then
		Goon.fromId({
			Id = card.GoonId,
			Battle = self,
			Direction = battler.Direction,
			Position = battler.Position,
			TeamId = battler.TeamId,
			Level = cardLevel,
		})
	else
		error(`Unimplemented card type {card.Type}`)
	end
end

function Battle.Update(self: Battle, dt: number)
	if self.State ~= "Active" then return end

	if self.RoundCooldown:IsReady() then
		self.RoundCooldown:Use()

		self.Trove:AddPromise(Promise.all({
			Promise.all(Sift.Array.map(self.Battlers, function(battler)
				return battler.DeckPlayer:ChooseCard():andThen(function(card)
					return { Battler = battler, Card = card }
				end)
			end)),
			Promise.delay(ChooseDuration),
		}):andThen(function(results)
			for _, cardChoice in results[1] do
				self:PlayCard(cardChoice.Battler, cardChoice.Card.Id, cardChoice.Card.Level)
			end
		end))
	end

	for object in self.Field do
		object:Update(dt)

		if not object:IsActive() then
			object:Destroy()
			self:Remove(object)
		end
	end

	local victor = self:GetVictor()
	if victor then self:End(victor) end
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

function Battle.DefaultFilter(_self: Battle, teamId: string)
	return function(object: BattleTarget)
		return object.TeamId ~= teamId
	end
end

function Battle.ForEachTarget(self: Battle, check: (BattleTarget) -> ())
	for target in self.Field do
		check(target)
	end

	for _, battler in self.Battlers do
		check(battler)
	end
end

function Battle.TargetNearest(
	self: Battle,
	args: {
		Position: number,
		Range: number,
		Filter: (BattleTarget) -> boolean,
	}
): BattleTarget?
	local bestTarget = nil
	local bestDistance = args.Range
	local filter = args.Filter

	self:ForEachTarget(function(target)
		if not filter(target) then return end

		local distance = math.abs(target.Position - args.Position)
		if distance < bestDistance then
			bestTarget = target
			bestDistance = distance
		end
	end)

	return bestTarget
end

function Battle.TargetEnemyBattler(self: Battle, teamId: string)
	local index = Sift.Array.findWhere(self.Battlers, function(battler)
		return battler.TeamId ~= teamId
	end)
	if not index then return nil end
	return self.Battlers[index]
end

function Battle.MoveFieldable(self: Battle, mover: Fieldable, movement: number)
	local direction = math.sign(movement)

	for object in self.Field do
		if object == mover then continue end

		local delta = object.Position - mover.Position
		if math.sign(delta) ~= direction then continue end

		delta = object.Position - (mover.Position + movement)
		local distance = math.abs(delta)
		local desiredDistance = (object.Size / 2) + (mover.Size / 2)
		local tooClose = distance < desiredDistance
		local movingPast = math.sign(delta) ~= direction
		if (not tooClose) and not movingPast then continue end

		local desiredPosition = object.Position + desiredDistance * -direction
		movement = desiredPosition - mover.Position
		if movement == 0 then return false end
	end

	local position = math.clamp(mover.Position + movement, 0, 1)
	if mover.Position == position then return false end

	mover.Position = position
	return true
end

function Battle.End(self: Battle, victor: Battler.Battler)
	if self.State ~= "Active" then return end

	self.State = "Ended"
	self.Ended:Fire(victor)
end

function Battle.Destroy(self: Battle)
	self.Trove:Clean()
	self.Destroyed:Fire()
end

return Battle
