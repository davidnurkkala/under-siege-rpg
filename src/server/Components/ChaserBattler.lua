local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local BattleHelper = require(ServerScriptService.Server.Util.BattleHelper)
local ChaserBattlerDefs = require(ServerScriptService.Server.ServerDefs.ChaserBattlerDefs)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
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
		CooldownsByPlayer: { [Player]: boolean },
		Def: any,
		Trove: any,
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

function ChaserBattler.FindTarget(self: ChaserBattler): (Player?, BasePart?)
	local bestTarget = nil
	local bestRange = self.Range

	for _, player in
		Sift.Array.filter(Players:GetPlayers(), function(filteringPlayer)
			return (not self.CooldownsByPlayer[filteringPlayer]) and (filteringPlayer:DistanceFromCharacter(self.Origin.Position) <= self.Range)
		end)
	do
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
	local target, root = self:FindTarget()

	if target and root then
		local delta = (root.Position - here) * Vector3.new(1, 0, 1)
		local distance = delta.Magnitude
		if distance > 4 then
			local traversed = math.min(distance, self.Def.Speed * dt)
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

function ChaserBattler.Destroy(self: ChaserBattler)
	self.Trove:Clean()
end

return ChaserBattler
