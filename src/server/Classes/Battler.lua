local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionService = require(ServerScriptService.Server.Services.ActionService)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local BaseDefs = require(ReplicatedStorage.Shared.Defs.BaseDefs)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local Damage = require(ServerScriptService.Server.Classes.Damage)
local EffectBattlerCollapse = require(ReplicatedStorage.Shared.Effects.EffectBattlerCollapse)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local Health = require(ReplicatedStorage.Shared.Classes.Health)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponHelper = require(ReplicatedStorage.Shared.Util.WeaponHelper)
local WeaponTypeDefs = require(ReplicatedStorage.Shared.Defs.WeaponTypeDefs)

local StartingSuppliesGain = 8
local SuppliesGainPerLevel = 2

local Battler = {}
Battler.__index = Battler

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
		WillDealDamage: any,
		Attacked: any,
		Battle: any?,
		TeamId: string,
		Active: boolean,
		Deck: { [string]: number },
		DeckCooldowns: { [string]: Cooldown.Cooldown },
		Animator: Animator.Animator,
		AttackDamage: number,
		Trove: any,
		Supplies: number,
		SuppliesGain: number,
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
	Deck: { [string]: number },
	Animator: Animator.Animator,
	WeaponDef: any,
}): Battler
	local trove = Trove.new()

	local weaponModel = trove:Add(WeaponHelper.AttachModel(args.WeaponDef, args.CharModel, args.WeaponHoldPart))

	local weaponType = args.WeaponDef.WeaponType
	local weaponTypeDef = WeaponTypeDefs[weaponType]

	local self: Battler = setmetatable({
		Health = Health.new(args.HealthMax),
		Position = args.Position,
		Direction = args.Direction,
		BaseModel = args.BaseModel,
		CharModel = args.CharModel,
		WeaponModel = weaponModel,
		WeaponDef = args.WeaponDef,
		TeamId = args.TeamId,
		Animator = args.Animator,
		Destroyed = Signal.new(),
		Changed = Signal.new(),
		WillDealDamage = Signal.new(),
		Attacked = Signal.new(),
		Active = true,
		AttackCooldown = Cooldown.new(5),
		Trove = trove,
		AttackDamage = weaponTypeDef.Damage,
		Deck = args.Deck,
		DeckCooldowns = Sift.Dictionary.map(args.Deck, function(_, cardId)
			local def = CardDefs[cardId]

			local cooldown = Cooldown.new(def.Cooldown)
			if def.Cooldown >= 10 then cooldown:Use() end

			return cooldown, cardId
		end),
		Supplies = 0,
		SuppliesGain = StartingSuppliesGain,
	}, Battler)

	self.AttackCooldown:Use()

	do
		local function update()
			self.Changed:Fire(self:GetStatus())
		end

		for _, cooldown in self:GetCooldowns() do
			self.Trove:Connect(cooldown.Used, update)
			self.Trove:Connect(cooldown.Completed, update)
		end
	end

	self.Animator:Play(self.WeaponDef.Animations.Idle)

	self.Trove:Add(function()
		self.Active = false
	end)

	self.Health:Observe(function(oldAmount, newAmount)
		local change = newAmount - oldAmount

		if change <= -2 then self:InjuryAnimation() end

		self.Changed:Fire(self:GetStatus())
	end)

	self.Trove:Add(task.spawn(function()
		while true do
			self.Changed:Fire(self:GetStatus())
			task.wait(0.5)
		end
	end))

	if weaponType == "Magic" then
		self.WillDealDamage:Connect(function(damage)
			if damage.Target:HasTag("Armored") then
				damage.Amount *= 1.1
			else
				damage.Amount *= 0.6
			end
		end)
	end

	return self
end

function Battler.fromBattlerId(battlerId: string, position: number, direction: number)
	local def = BattlerDefs[battlerId]
	assert(def, `No def found for battler id {battlerId}`)

	local baseDef = BaseDefs[def.BaseId]
	local base = baseDef.Model:Clone()

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
		Deck = def.Deck,
		Animator = Animator.new(char.Humanoid),
		HealthMax = 50,
	})

	battler.Destroyed:Connect(function()
		char:Destroy()
	end)

	return battler
end

function Battler.Is(object)
	return getmetatable(object) == Battler
end

function Battler.HasTag(self: Battler, tagId: string)
	local weaponType = self.WeaponDef.WeaponType

	if weaponType == "Magic" or weaponType == "Crossbow" then
		return false
	else
		return tagId == "Ranged"
	end
end

function Battler.GetCooldowns(self: Battler)
	return Sift.Array.append(Sift.Dictionary.values(self.DeckCooldowns), self.AttackCooldown)
end

function Battler.DefeatAnimation(self: Battler)
	return Promise.try(function()
		self.Animator:Play("GenericBattlerDie", 0)

		EffectService:ForBattle(
			self.Battle,
			EffectBattlerCollapse({
				CharModel = self.CharModel,
				BaseModel = self.BaseModel,
			})
		)

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

function Battler.GetStatus(self: Battler)
	return {
		BaseModel = self.BaseModel,
		CharModel = self.CharModel,
		Health = self.Health:Get(),
		HealthMax = self.Health.Max,
		AttackCooldown = { Time = self.AttackCooldown.Time, TimeMax = self.AttackCooldown.TimeMax },
		DeckCooldowns = Sift.Dictionary.map(self.DeckCooldowns, function(cooldown)
			return { Time = cooldown.Time, TimeMax = cooldown.TimeMax }
		end),
		Supplies = math.floor(self.Supplies),
		SuppliesGain = math.floor(self.SuppliesGain),
		SuppliesUpgradeCost = self:GetSuppliesUpgradeCost(),
	}
end

function Battler.GetSuppliesUpgradeCost(self: Battler)
	return 50 + 30 * (self.SuppliesGain - StartingSuppliesGain)
end

function Battler.UpgradeSupplies(self: Battler)
	local cost = self:GetSuppliesUpgradeCost()
	if self.Supplies < cost then return end

	self.Supplies -= cost
	self.SuppliesGain += SuppliesGainPerLevel

	self.Changed:Fire(self:GetStatus())
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
	if not self.AttackCooldown:IsReady() then return false end

	local battle = self.Battle
	if not battle then return false end
	if battle.State == "Ended" then return false end

	local target = battle:TargetNearest({
		Position = self.Position,
		Range = math.huge,
		Filter = battle:EnemyFilter(self.TeamId),
	})

	if not target then return false end

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

			EffectService:ForBattle(
				self.Battle,
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
				battle:Damage(Damage.new(self, target, self.AttackDamage))

				EffectService:ForBattle(
					self.Battle,
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
			end)
		end)
		:catch(function() end)

	local cancelPromise = Promise.fromEvent(target.Destroyed):andThen(function()
		self.Animator:StopHard(self.WeaponDef.Animations.Shoot)
		self.AttackCooldown:Reset()
	end)

	Promise.race({ attackPromise, cancelPromise })

	self.Attacked:Fire()

	return true
end

function Battler.Destroy(self: Battler)
	self.Trove:Clean()
	self.Destroyed:Fire()
end

return Battler
