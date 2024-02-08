local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local BattleService = require(ServerScriptService.Server.Services.BattleService)
local BattleSession = require(ServerScriptService.Server.Classes.BattleSession)
local Battler = require(ServerScriptService.Server.Classes.Battler)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local BattlerHelper = require(ServerScriptService.Server.Util.BattlerHelper)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local Configuration = require(ReplicatedStorage.Shared.Configuration)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Damage = require(ServerScriptService.Server.Classes.Damage)
local EffectPart = require(ReplicatedStorage.Shared.Util.EffectPart)
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local Goon = require(ServerScriptService.Server.Classes.Goon)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local MusicService = require(ServerScriptService.Server.Services.MusicService)
local PartPath = require(ReplicatedStorage.Shared.Classes.PartPath)
local Promise = require(ReplicatedStorage.Packages.Promise)
local RewardHelper = require(ServerScriptService.Server.Util.RewardHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local Battle = {}
Battle.__index = Battle

local BattleUpdater = Updater.new()

type Fieldable = {
	Position: number,
	GetSize: (Fieldable) -> number,
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
		Timer: number,
		CardPlayers: any,
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
		Ended = Signal.new(),
		Finished = Signal.new(),
		Destroyed = Signal.new(),
		Changed = Signal.new(),
		State = "Active",
		Timer = 0,
		CardPlayed = Signal.new(),
	}, Battle)

	for _, entry in { { self.Battlers[1], self.Model.Spawns.Left }, { self.Battlers[2], self.Model.Spawns.Right } } do
		local battler, part = entry[1], entry[2]
		local base, char = battler.BaseModel, battler.CharModel

		base:PivotTo(part.CFrame)
		base.Parent = self.Model

		local delta = if Players:GetPlayerFromCharacter(char) ~= nil
			then TryNow(function()
				return Vector3.new(0, char.Humanoid.HipHeight + char.PrimaryPart.Size.Y / 2, 0)
			end, Vector3.zero)
			else Vector3.zero

		char:PivotTo(base.Spawn.CFrame + delta)
		base.Spawn.Transparency = 1

		battler:Observe(function()
			self.Changed:Fire(self:GetStatus())
		end)
	end

	self.Model.Spawns:Destroy()
	self.Model:SetAttribute(
		"UserIds",
		table.concat(
			Sift.Array.map(self.Battlers, function(battler)
				local player = Players:GetPlayerFromCharacter(battler.CharModel)
				if player then
					return player.UserId
				else
					return nil
				end
			end),
			","
		)
	)
	self.Model.Parent = workspace.Battles
	self.Trove:Add(self.Model)

	local halfway = EffectPart()
	halfway.Color = Color3.new(1, 1, 1)
	halfway.Material = Enum.Material.Neon
	halfway.Transparency = 0.5
	halfway.Size = Vector3.new(0.5, 0.5, 8)
	halfway.CFrame = CFrame.new(self.Path:ToWorld(0.5))
	halfway.Parent = self.Model

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

function Battle.fromPlayerVersusBattler(player: Player, battlerId: string, playerBattlerOverrides: any)
	return BattleService:Promise(player, function()
		return Promise.new(function(resolve, reject)
			if BattleService:Get(player) then
				reject(`Player {player} already has a battle`)
				return
			end

			resolve(BattleSession.promised(player, 0, 1, playerBattlerOverrides))
		end):andThen(function(battleSession)
			local battlerDef = BattlerDefs[battlerId]
			assert(battlerDef, `No battler found for id {battlerId}`)

			MusicService:SetSoundtrack(player, battlerDef.Soundtrack)

			local battleground = ReplicatedStorage.Assets.Models.Battlegrounds[battlerDef.BattlegroundName]:Clone()
			local opponent = Battler.fromBattlerId(battlerId, 1, -1)

			local battle = Battle.new({
				Battlers = { battleSession.Battler, opponent },
				Model = battleground,
			})

			local opponentBrain = BattlerHelper.CreateBrain(battlerId, opponent)

			BattleService:Add(player, battle)
			battle.Ended:Connect(function(victor)
				if victor ~= battleSession.Battler then
					EventStream.Event({ Kind = "BattleLost", Player = player, BattlerId = battlerId })
					BattleService.MessageSent:Fire(player, "Defeat...")
					return
				end

				local def = BattlerDefs[battlerId]
				local rewards = RewardHelper.ProcessChanceTable(player, def.Rewards)

				Promise.all(Sift.Array.map(rewards, function(reward)
					return RewardHelper.GiveReward(player, reward)
				end))
					:andThen(function(givenRewards)
						BattleService.RewardsDisplayed:Fire(player, givenRewards)
					end)
					:andThen(function()
						EventStream.Event({ Kind = "BattleWon", Player = player, BattlerId = battlerId })
					end)
			end)
			battle.Destroyed:Connect(function()
				BattleService:Remove(player)
				opponentBrain:Destroy()
			end)

			EventStream.Event({ Kind = "BattleStarted", Player = player, BattlerId = battlerId })

			return battle
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
	return function()
		connection:Disconnect()
	end
end

function Battle.Add(self: Battle, object: Fieldable)
	if self.Field[object] then return end

	self.Field[object] = true
end

function Battle.Remove(self: Battle, object: Fieldable)
	if not self.Field[object] then return end

	self.Field[object] = nil
end

function Battle.PlayCard(self: Battle, battler: Battler.Battler, cardId: string)
	return Promise.try(function()
		if self.State ~= "Active" then return end

		if not cardId then return end

		local card = CardDefs[cardId]
		assert(card, `No card for id {cardId}`)

		local level = battler.Deck[cardId]
		if not level then return end

		local cooldown = battler.DeckCooldowns[cardId]
		if not cooldown:IsReady() then return end

		local canAfford = battler.Supplies > card.Cost
		if not canAfford then return end

		battler.Supplies -= card.Cost
		cooldown:Use()

		local retVal

		if card.Type == "Goon" then
			retVal = Goon.fromId({
				Id = card.GoonId,
				Battle = self,
				Battler = battler,
				Direction = battler.Direction,
				Position = battler.Position,
				TeamId = battler.TeamId,
				Level = level,
			})

			retVal.Died:Connect(function()
				if Configuration.BountyDisabled then return end

				local bounty = math.max(1, math.floor(card.Cost * 0.1))
				for _, otherBattler in self.Battlers do
					if otherBattler == battler then continue end
					otherBattler.Supplies += bounty

					-- TODO: replace with better player acquisition pipeline
					local player = Players:GetPlayerFromCharacter(otherBattler.CharModel)
					if not player then continue end

					GuiEffectService.IndicatorRequestedRemote:Fire(player, {
						Text = `+{bounty}`,
						Image = CurrencyDefs.Supplies.Image,
						Start = retVal:GetRoot().Position,
						Finish = otherBattler:GetRoot().Position,
					})
				end
			end)
		elseif card.Type == "Ability" then
			retVal = self:ActivateAbility(card.AbilityId, level, battler)
		else
			error(`Unimplemented card type {card.Type}`)
		end

		self.CardPlayed:Fire(battler, cardId, level)

		return retVal
	end)
end

function Battle.ActivateAbility(self: Battle, abilityId: string, level: number, battler: Battler.Battler)
	local activate = AbilityHelper.GetImplementation(abilityId)

	return Promise.race({
		activate(level, battler, self),
		Promise.fromEvent(self.Ended),
	})
end

function Battle.Update(self: Battle, dt: number)
	if self.State ~= "Active" then return end

	self.Timer += dt

	for object in self.Field do
		object:Update(dt)

		if not object:IsActive() then
			object:Destroy()
			self:Remove(object)
		end
	end

	for _, battler in self.Battlers do
		battler.Supplies += battler.SuppliesGain * dt
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

function Battle.EnemyFilter(_self: Battle, teamId: string)
	return function(object: BattleTarget)
		return object.TeamId ~= teamId
	end
end

function Battle.EnemyGoonsFilter(_self: Battle, teamId: string)
	return function(object: BattleTarget)
		return Goon.Is(object) and object.TeamId ~= teamId
	end
end

function Battle.AllyFilter(_self: Battle, teamId: string)
	return function(object: BattleTarget)
		return object.TeamId == teamId
	end
end

function Battle.AllyGoonsFilter(_self: Battle, teamId: string)
	return function(object: BattleTarget)
		return Goon.Is(object) and object.TeamId == teamId
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

function Battle.FilterTargets(self: Battle, filter: (BattleTarget) -> boolean)
	return Sift.Array.filter(Sift.Array.concat(Sift.Dictionary.keys(self.Field), self.Battlers), filter)
end

function Battle.TargetAll(
	self: Battle,
	args: {
		Filter: (BattleTarget) -> boolean,
	}
)
	return self:FilterTargets(args.Filter)
end

function Battle.TargetFarToClose(
	self: Battle,
	args: {
		Battler: Battler.Battler,
		Filter: (BattleTarget) -> boolean,
	}
)
	local compare = if args.Battler.Position < 0.5
		then function(a, b)
			return a.Position > b.Position
		end
		else function(a, b)
			return a.Position < b.Position
		end

	return Sift.Array.sort(self:FilterTargets(args.Filter), compare)
end

function Battle.TargetCloseToFar(
	self: Battle,
	args: {
		Battler: Battler.Battler,
		Filter: (BattleTarget) -> boolean,
	}
)
	local compare = if args.Battler.Position < 0.5
		then function(a, b)
			return a.Position < b.Position
		end
		else function(a, b)
			return a.Position > b.Position
		end

	return Sift.Array.sort(self:FilterTargets(args.Filter), compare)
end

function Battle.TargetRadius(
	self: Battle,
	args: {
		Position: number,
		Radius: number,
		Filter: (BattleTarget) -> boolean,
	}
): { BattleTarget }
	return self:FilterTargets(function(target)
		if not args.Filter(target) then return false end

		local distance = math.abs(target.Position - args.Position)
		return distance <= args.Radius
	end)
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

function Battle.TargetFurthest(
	self: Battle,
	args: {
		Position: number,
		Filter: (BattleTarget) -> boolean,
	}
): BattleTarget?
	local bestTarget = nil
	local bestDistance = -1
	local filter = args.Filter

	self:ForEachTarget(function(target)
		if not filter(target) then return end

		local distance = math.abs(target.Position - args.Position)
		if distance > bestDistance then
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
	local moverSize = mover:GetSize()

	for object in self.Field do
		if object == mover then continue end
		if object.TeamId == mover.TeamId then continue end

		local delta = object.Position - mover.Position
		if math.sign(delta) ~= direction then continue end

		delta = object.Position - (mover.Position + movement)
		local distance = math.abs(delta)
		local desiredDistance = (object:GetSize() / 2) + (moverSize / 2)
		local tooClose = distance < desiredDistance
		local movingPast = math.sign(delta) ~= direction
		if (not tooClose) and not movingPast then continue end

		local desiredPosition = object.Position + desiredDistance * -direction
		movement = desiredPosition - mover.Position
		if movement == 0 then return false end
	end

	local halfSize = moverSize / 2
	local position = math.clamp(mover.Position + movement, halfSize, 1 - halfSize)
	if mover.Position == position then return false end

	mover.Position = position
	return true
end

function Battle.Damage(self: Battle, damage: Damage.Damage)
	local source, target = damage.Source, damage.Target

	if source.WillDealDamage then source.WillDealDamage:Fire(damage) end
	if target.WillTakeDamage then target.WillTakeDamage:Fire(damage) end

	damage.Amount = math.max(damage.Amount, 0)

	if damage.Amount > 0 then target.Health:Adjust(-damage.Amount) end

	-- show an indicator
	local text = damage:GetText()

	for _, battler in self.Battlers do
		-- TODO: replace with better player acquisition pipeline
		local player = Players:GetPlayerFromCharacter(battler.CharModel)
		if not player then continue end

		GuiEffectService.DamageNumberRequestedRemote:Fire(player, {
			TextProps = {
				Text = text,
			},
			Position = damage.Target:GetWorldCFrame().Position,
		})
	end

	if source.DidDealDamage then source.DidDealDamage:Fire(damage) end
	if target.DidTakeDamage then target.DidTakeDamage:Fire(damage) end
end

function Battle.End(self: Battle, victor: Battler.Battler)
	if self.State ~= "Active" then return end

	self.State = "Ended"
	self.Ended:Fire(victor)

	for object in self.Field do
		if Goon.Is(object) then
			object.Brain:Destroy()

			if object.TeamId == victor.TeamId then
				object:VictoryAnimation()
			else
				object:DefeatAnimation()
			end
		end
	end

	Promise.all(Sift.Array.map(
		Sift.Array.filter(self.Battlers, function(battler)
			return battler ~= victor
		end),
		function(loser)
			return loser:DefeatAnimation()
		end
	)):andThen(function()
		self.Finished:Fire()
	end)
end

function Battle.Destroy(self: Battle)
	self.Trove:Clean()
	self.Destroyed:Fire()
end

return Battle
