local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local BattleHelper = require(ServerScriptService.Server.Util.BattleHelper)
local ChaserBattlerDefs = require(ServerScriptService.Server.ServerDefs.ChaserBattlerDefs)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Promise = require(ReplicatedStorage.Packages.Promise)
local RewardHelper = require(ServerScriptService.Server.Util.RewardHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Stat = require(ServerScriptService.Server.Classes.Stat)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local ChaserBattlerUpdater = Updater.new()

local ChaserBattler = {}
ChaserBattler.__index = ChaserBattler

export type ChaserBattler = typeof(setmetatable(
	{} :: {
		Model: Model,
		Animator: Animator.Animator?,
		Origin: CFrame,
		Range: number,
		ThreatenedPlayers: { [Player]: boolean },
		CooldownsByPlayer: { [Player]: boolean },
		Def: any,
		Trove: any,
		ActiveSlow: any,
	},
	ChaserBattler
))

function ChaserBattler.new(model: Model): ChaserBattler
	local id = model:GetAttribute("ChaserBattlerId")
	assert(id, `ChaserBattler {model:GetFullName()} missing id`)

	local def = ChaserBattlerDefs[id]
	assert(def, `ChaserBattlerDef {id} does not exist`)

	local self: ChaserBattler = setmetatable({
		Model = model,
		Animator = Animator.fromModel(model),
		Origin = model:GetPivot(),
		Range = model:GetAttribute("ChaserBattlerRange") or 32,
		CooldownsByPlayer = {},
		ThreatenedPlayers = {},
		Def = def,
		Trove = Trove.new(),
	}, ChaserBattler)

	ChaserBattlerUpdater:Add(self)
	self.Trove:Add(function()
		ChaserBattlerUpdater:Remove(self)
	end)

	self:WithAnimator(function(animator)
		self.Trove:Add(animator)

		animator:Play(self.Def.Animations.Idle)
	end)

	return self
end

function ChaserBattler.WithAnimator(self: ChaserBattler, callback: (Animator.Animator) -> ())
	if self.Animator then callback(self.Animator) end
end

function ChaserBattler.GetPlayersInRange(self: ChaserBattler): { Player }
	return Sift.Array.filter(Players:GetPlayers(), function(filteringPlayer)
		return (not self.CooldownsByPlayer[filteringPlayer]) and (filteringPlayer:DistanceFromCharacter(self.Origin.Position) <= self.Range)
	end)
end

function ChaserBattler.FindTarget(self: ChaserBattler, players: { Player }): (Player?, BasePart?)
	local bestTarget = nil
	local bestRange = self.Range

	for _, player in players do
		local range = player:DistanceFromCharacter(self.Model:GetPivot().Position)
		if range < bestRange then
			bestTarget = player
			bestRange = range
		end
	end

	if not bestTarget then return end

	local char = bestTarget.Character
	if not char then return end
	if not char.PrimaryPart then return end

	return bestTarget, char.PrimaryPart
end

function ChaserBattler.Update(self: ChaserBattler, dt: number)
	local here = self.Model:GetPivot().Position
	local playersInRange = self:GetPlayersInRange()
	local target, root = self:FindTarget(playersInRange)

	local newThreatenedPlayers = Sift.Array.toSet(playersInRange)
	for player in self.ThreatenedPlayers do
		if not Sift.Set.has(newThreatenedPlayers, player) then
			local session = LobbySessions.Get(player)
			if not session then continue end

			if session.WeaponTarget:Get() == self then session.WeaponTarget:Set(nil) end
		end
	end
	for player in newThreatenedPlayers do
		if not Sift.Set.has(self.ThreatenedPlayers, player) then
			local session = LobbySessions.Get(player)
			if not session then continue end

			session.WeaponTarget:Set(self)
		end
	end
	self.ThreatenedPlayers = newThreatenedPlayers

	if target and root then
		local delta = (root.Position - here) * Vector3.new(1, 0, 1)
		local distance = delta.Magnitude
		if distance > 2.5 then
			local speed = if self.ActiveSlow then 12 else self.Def.Speed
			local traversed = math.min(distance, speed * dt)
			self.Model:PivotTo(CFrame.lookAlong(here + (delta / distance) * traversed, delta))

			self:WithAnimator(function(animator)
				animator:Play(self.Def.Animations.Walk)
			end)
		else
			self.CooldownsByPlayer[target] = true

			BattleHelper.FadeToBattle(target, self.Def.BattlerId, self.Origin)
				:andThen(function(playerWon)
					if not playerWon then
						return self.Def.OnDefeat(target)
					else
						return Promise.resolve()
					end
				end)
				:finally(function()
					task.delay(60 * 2.5, function()
						self.CooldownsByPlayer[target] = nil
					end)
				end)

			self:WithAnimator(function(animator)
				animator:StopHard(self.Def.Animations.Walk)
			end)
		end
	else
		local delta = self.Origin.Position - self.Model:GetPivot().Position
		local distance = delta.Magnitude
		if distance > 1 then
			local traversed = math.min(distance, self.Def.Speed * dt)
			self.Model:PivotTo(CFrame.lookAlong(here + (delta / distance) * traversed, delta * Vector3.new(1, 0, 1)))

			self:WithAnimator(function(animator)
				animator:Play(self.Def.Animations.Walk)
			end)
		else
			self:WithAnimator(function(animator)
				animator:StopHard(self.Def.Animations.Walk)
			end)
		end
	end
end

function ChaserBattler.GetRoot(self: ChaserBattler)
	return self.Model.PrimaryPart
end

function ChaserBattler.GetPosition(self: ChaserBattler)
	return self:GetRoot().Position
end

function ChaserBattler.OnHit(self: ChaserBattler, lobbySession)
	if self.ActiveSlow then self.ActiveSlow:cancel() end

	self.ActiveSlow = Promise.delay(1):andThen(function()
		self.ActiveSlow = nil
	end)

	EffectService:All(EffectEmission({
		Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
		ParticleCount = 2,
		Target = self:GetPosition(),
	}))

	return RewardHelper.GiveReward(lobbySession.Player, { Type = "Currency", CurrencyType = "Glory", Amount = 2 }):andThen(function(reward)
		GuiEffectService.IndicatorRequestedRemote:Fire(lobbySession.Player, {
			Text = `+{reward.Amount // 1}`,
			Image = CurrencyDefs.Glory.Image,
			Start = self:GetPosition(),
			EndGui = "GuiPanelGlory",
		})
	end)
end

function ChaserBattler.Destroy(self: ChaserBattler)
	self.Trove:Clean()
end

return ChaserBattler
