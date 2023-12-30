local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local BattleService = require(ServerScriptService.Server.Services.BattleService)
local BattleSession = require(ServerScriptService.Server.Classes.BattleSession)
local Battler = require(ServerScriptService.Server.Classes.Battler)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local Damage = require(ServerScriptService.Server.Classes.Damage)
local Default = require(ReplicatedStorage.Shared.Util.Default)
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local Goon = require(ServerScriptService.Server.Classes.Goon)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local PartPath = require(ReplicatedStorage.Shared.Classes.PartPath)
local ProductService = require(ServerScriptService.Server.Services.ProductService)
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
		CritEnabled: boolean,
		Timer: number,
	},
	Battle
))

function Battle.new(args: {
	Model: BattlegroundModel,
	Battlers: { Battler.Battler },
	CritEnabled: boolean?,
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
		CritEnabled = Default(args.CritEnabled, true),
		Timer = 0,
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

	for _, battler in self.Battlers do
		self:DeployStartingGoons(battler)
	end

	return self
end

function Battle.fromPlayerVersusBattler(player: Player, battlerId: string)
	return BattleService:Promise(player, function()
		return Promise.new(function(resolve, reject)
			if BattleService:Get(player) then
				reject(`Player {player} already has a battle`)
				return
			end

			resolve(BattleSession.promised(player, 0, 1))
		end):andThen(function(battleSession)
			local battlerDef = BattlerDefs[battlerId]
			assert(battlerDef, `No battler found for id {battlerId}`)

			local battleground = ReplicatedStorage.Assets.Models.Battlegrounds[battlerDef.BattlegroundName]:Clone()
			local opponent = Battler.fromBattlerId(battlerId, 1, -1)

			local battle = Battle.new({
				Battlers = { battleSession.Battler, opponent },
				Model = battleground,
			})

			BattleService:Add(player, battle)
			battle.Ended:Connect(function(victor)
				if victor ~= battleSession.Battler then
					EventStream.Event({ Kind = "BattleLost", Player = player, BattlerId = battlerId })
					BattleService.MessageSent:Fire(player, "Defeat...")
					return
				end

				local def = BattlerDefs[battlerId]
				local reward = def.Reward

				CurrencyService:GetBoosted(player, "Secondary", reward)
					:andThen(function(amountAdded)
						amountAdded = ProductService:GetVipBoostedSecondary(player, amountAdded)

						BattleService.MessageSent:Fire(player, "Victory!")

						GuiEffectService.IndicatorRequestedRemote:Fire(player, {
							Text = `+{amountAdded // 0.1 / 10}`,
							Image = CurrencyDefs.Secondary.Image,
							Start = opponent:GetRoot().Position,
							Finish = victor:GetRoot().Position,
							Mode = "Slow",
						})

						Promise.delay(0.5):andThen(function()
							CurrencyService:AddCurrency(player, "Secondary", amountAdded)
						end)
					end)
					:andThen(function()
						EventStream.Event({ Kind = "BattleWon", Player = player, BattlerId = battlerId })
					end)
			end)
			battle.Destroyed:Connect(function()
				BattleService:Remove(player)
			end)

			return battle
		end)
	end)
end

function Battle.GetStatus(self: Battle)
	return {
		CritEnabled = self.CritEnabled,
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

function Battle.DeployStartingGoons(self: Battle, battler: Battler.Battler)
	local cards = battler.DeckPlayer.Deck.Cards
	local goonCardIds = Sift.Array.shuffle(Sift.Array.filter(Sift.Dictionary.keys(cards), function(cardId)
		return CardDefs[cardId].Type == "Goon"
	end))
	if #goonCardIds == 0 then return end

	local index = 1
	for number = 1, 3 do
		local cardId = goonCardIds[index]

		index += 1
		if index > #goonCardIds then index = 1 end

		Promise.delay(number * 0.75):andThen(function()
			if self.State ~= "Active" then return end

			self:PlayCard(battler, cardId, cards[cardId])
		end)
	end
end

function Battle.PlayCard(self: Battle, battler: Battler.Battler, cardId: string, cardCount: number)
	if not cardId then return end

	local card = CardDefs[cardId]
	assert(card, `No card for id {cardId}`)

	local level = CardHelper.CountToLevel(cardCount)

	BattleService.CardPlayed:FireFor(BattleService:GetPlayersFromBattle(self), {
		Position = battler.Position,
		CardId = cardId,
		CardCount = cardCount,
	})

	if card.Type == "Goon" then
		return Promise.resolve(Goon.fromId({
			Id = card.GoonId,
			Battle = self,
			Battler = battler,
			Direction = battler.Direction,
			Position = battler.Position,
			TeamId = battler.TeamId,
			Level = level,
		}))
	elseif card.Type == "Ability" then
		local activate = AbilityHelper.GetImplementation(card.AbilityId)
		return activate(level, battler, self)
	else
		error(`Unimplemented card type {card.Type}`)
	end
end

function Battle.Update(self: Battle, dt: number)
	if self.State ~= "Active" then return end

	self.Timer += dt

	if (self.Timer >= 1) and self.RoundCooldown:IsReady() then
		self.RoundCooldown:Use()

		self.Trove:AddPromise(Promise.all({
			Promise.all(Sift.Array.map(self.Battlers, function(battler)
				return battler.DeckPlayer:ChooseCard():andThen(function(card)
					return { Battler = battler, Card = card }
				end)
			end)),
			Promise.delay(ChooseDuration),
		}):andThen(function(results)
			if self.State ~= "Active" then return end

			for _, cardChoice in results[1] do
				self:PlayCard(cardChoice.Battler, cardChoice.Card.Id, cardChoice.Card.Count)
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

function Battle.AllyFilter(_self: Battle, teamId: string)
	return function(object: BattleTarget)
		return object.TeamId == teamId
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

	for object in self.Field do
		if object == mover then continue end
		if object.TeamId == mover.TeamId then continue end

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

	local halfSize = mover.Size / 2
	local position = math.clamp(mover.Position + movement, halfSize, 1 - halfSize)
	if mover.Position == position then return false end

	mover.Position = position
	return true
end

function Battle.Damage(self: Battle, damage: Damage.Damage)
	local source, target = damage.Source, damage.Target

	local attackPower = if Battler.Is(source) then source.Power else source.Battler.Power
	local defendPower = if Battler.Is(target) then target.Power else target.Battler.Power

	local advantage = math.sqrt(attackPower / defendPower)
	damage:SetRaw(damage.Amount * advantage)

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

	for _, battler in self.Battlers do
		battler.DeckPlayer:Destroy()
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
