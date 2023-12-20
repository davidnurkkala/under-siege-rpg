local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local Deck = require(ServerScriptService.Server.Classes.Deck)
local DeckPlayerRandom = require(ServerScriptService.Server.Classes.DeckPlayerRandom)
local EffectBattlerCollapse = require(ReplicatedStorage.Shared.Effects.EffectBattlerCollapse)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectGrowFade = require(ReplicatedStorage.Shared.Effects.EffectGrowFade)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local Health = require(ReplicatedStorage.Shared.Classes.Health)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponHelper = require(ReplicatedStorage.Shared.Util.WeaponHelper)

local AttackSlowdown = 0.4

local Battler = {}
Battler.__index = Battler

type DeckPlayer = {
	ChooseCard: (DeckPlayer) -> any,
} | any

export type Battler = typeof(setmetatable(
	{} :: {
		Health: Health.Health,
		Position: number,
		Direction: number,
		BaseModel: Model,
		CharModel: Model,
		WeaponModel: Model,
		WeaponDef: any,
		Destroyed: any,
		Battle: any?,
		TeamId: string,
		Active: boolean,
		DeckPlayer: DeckPlayer,
		Animator: Animator.Animator,
		Power: number,
		AttackDamage: number,
		Trove: any,
		Crit: number,
	},
	Battler
))

function Battler.new(args: {
	HealthMax: number,
	Position: number,
	Direction: number,
	BaseModel: Model,
	CharModel: Model,
	WeaponHoldPart: BasePart,
	TeamId: string,
	DeckPlayer: DeckPlayer,
	Animator: Animator.Animator,
	WeaponDef: any,
	Power: number,
}): Battler
	local trove = Trove.new()

	local weaponModel = trove:Add(WeaponHelper.attachModel(args.WeaponDef, args.CharModel, args.WeaponHoldPart))

	local damagePerSecond = 1
	local attacksPerSecond = 1 / (args.WeaponDef.AttackCooldownTime / AttackSlowdown)
	local attackDamage = damagePerSecond / attacksPerSecond

	local self: Battler = setmetatable({
		Health = Health.new(args.HealthMax),
		Position = args.Position,
		Direction = args.Direction,
		BaseModel = args.BaseModel,
		CharModel = args.CharModel,
		WeaponModel = weaponModel,
		WeaponDef = args.WeaponDef,
		TeamId = args.TeamId,
		DeckPlayer = args.DeckPlayer,
		Animator = args.Animator,
		Destroyed = Signal.new(),
		Changed = Signal.new(),
		Active = true,
		AttackCooldown = Cooldown.new(args.WeaponDef.AttackCooldownTime / AttackSlowdown),
		Trove = trove,
		Power = args.Power,
		AttackDamage = attackDamage,
		Crit = 0,
	}, Battler)

	self.Animator:Play(self.WeaponDef.Animations.Idle)

	self.Trove:AddPromise(Promise.delay(2.5):andThen(function()
		self.Trove:Add(self.AttackCooldown:OnReady(function()
			self:Attack()
		end))
	end))

	self.Trove:Add(function()
		self.Active = false
	end)

	self.Health:Observe(function(oldAmount, newAmount)
		local change = newAmount - oldAmount

		if change <= -2 then self:InjuryAnimation() end

		self.Changed:Fire(self:GetStatus())
	end)

	return self
end

function Battler.fromBattlerId(battlerId: string, position: number, direction: number)
	local def = BattlerDefs[battlerId]
	assert(def, `No def found for battler id {battlerId}`)

	local base = ReplicatedStorage.Assets.Models.Bases[def.BaseName]:Clone()

	local char = def.Model:Clone()
	char.Parent = workspace

	local weaponDef = WeaponDefs[def.WeaponId]
	assert(weaponDef, `No weapon def found for id {def.WeaponId}`)

	local holdPart = char:FindFirstChild(weaponDef.HoldPartName)

	local battler = Battler.new({
		BaseModel = base,
		CharModel = char,
		WeaponHoldPart = holdPart,
		WeaponDef = weaponDef,
		Position = position,
		Direction = direction,
		TeamId = `NON_PLAYER_{battlerId}`,
		DeckPlayer = DeckPlayerRandom.new(Deck.new(def.Deck)),
		Animator = Animator.new(char.Humanoid),
		HealthMax = 50,
		Power = def.Power,
	})

	battler.Destroyed:Connect(function()
		char:Destroy()
	end)

	return battler
end

function Battler.Is(object)
	return getmetatable(object) == Battler
end

function Battler.DefeatAnimation(self: Battler)
	return Promise.try(function()
		self.Animator:Play("GenericBattlerDie", 0)

		EffectService:All(EffectBattlerCollapse({
			CharModel = self.CharModel,
			BaseModel = self.BaseModel,
		}))

		return Promise.delay(2.5)
	end):catch(function() end)
end

function Battler.InjuryAnimation(self: Battler)
	self.Animator:Play("GenericBattlerFlinch", 0)
end

function Battler.GetWorldCFrame(self: Battler)
	local cframe = self.BaseModel:GetBoundingBox()
	return cframe
end

function Battler.GetRoot(self: Battler): BasePart
	local root = self.CharModel.PrimaryPart
	assert(root, `No primary part in char root`)
	return root
end

function Battler.SetBattle(self: Battler, battle)
	self.Battle = battle
end

function Battler.GetBattle(self: Battler)
	return self.Battle
end

function Battler.AddCrit(self: Battler, amount: number)
	self:SetCrit(self.Crit + amount)
end

function Battler.SetCrit(self: Battler, amount: number)
	amount = math.clamp(amount, 0, 1)
	if self.Crit == amount then return end

	self.Crit = amount
	self.Changed:Fire(self:GetStatus())
end

function Battler.GetStatus(self: Battler)
	return {
		BaseModel = self.BaseModel,
		CharModel = self.CharModel,
		Health = self.Health:Get(),
		HealthMax = self.Health.Max,
		Crit = self.Crit,
	}
end

function Battler.Observe(self: Battler, callback)
	local connection = self.Changed:Connect(callback)
	callback(self:GetStatus())
	return connection
end

function Battler.IsActive(self: Battler)
	if not self.Active then return false end

	return self.Health:Get() > 0
end

function Battler.Attack(self: Battler)
	if not self.AttackCooldown:IsReady() then return end

	local battle = self.Battle
	if not battle then return end
	if battle.State == "Ended" then return end

	local target = battle:TargetNearest({
		Position = self.Position,
		Range = math.huge,
		Filter = battle:DefaultFilter(self.TeamId),
	})

	if not target then return end

	local root = target:GetRoot()

	self.AttackCooldown:Use()

	self.Animator:Play(self.WeaponDef.Animations.Shoot, 0)

	local attackPromise = Promise.delay(0.05)
		:andThen(function()
			local part = self.WeaponModel:FindFirstChild("Weapon")
			local here = part.Position
			local there = root.Position
			local start = CFrame.lookAt(here, there)
			local speed = 128

			local isCrit = self.Crit >= 1
			if isCrit then
				self:SetCrit(0)

				EffectService:All(
					EffectProjectile({
						Model = ReplicatedStorage.Assets.Models.Effects.CritProjectile,
						Start = start,
						Finish = root,
						Speed = speed,
					}),
					EffectSound({
						SoundId = "CritStart1",
						Target = part,
					})
				)
			end

			EffectService:All(
				EffectProjectile({
					Model = ReplicatedStorage.Assets.Models.Projectiles[self.WeaponDef.ProjectileName],
					Start = start,
					Finish = root,
					Speed = speed,
				}),
				EffectSound({
					SoundId = PickRandom(self.WeaponDef.Sounds.Shoot),
					Target = part,
				})
			):andThen(function()
				battle:Damage(self, target, self.AttackDamage * if isCrit then 5 else 1)

				EffectService:All(
					EffectSound({
						SoundId = PickRandom(self.WeaponDef.Sounds.Hit),
						Target = target:GetWorldCFrame().Position,
					}),
					EffectEmission({
						Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
						ParticleCount = 2,
						Target = root,
					})
				)

				if isCrit then
					EffectService:All(
						EffectGrowFade({
							Part = ReplicatedStorage.Assets.Models.Effects.CritHitEffect,
							Target = root,
							Duration = 0.25,
							StartSize = Vector3.zero,
							EndSize = Vector3.one * 20,
						}),
						EffectSound({
							SoundId = "CritImpact1",
							Target = root,
						})
					)
				end
			end)
		end)
		:catch(function() end)

	local cancelPromise = Promise.fromEvent(target.Destroyed):andThen(function()
		self.Animator:StopHard(self.WeaponDef.Animations.Shoot)
		self.AttackCooldown:Reset()
	end)

	return Promise.race({ attackPromise, cancelPromise })
end

function Battler.Destroy(self: Battler)
	self.Trove:Clean()
	self.Destroyed:Fire()
end

return Battler
