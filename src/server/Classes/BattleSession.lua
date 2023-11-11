local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionService = require(ServerScriptService.Server.Services.ActionService)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local Battler = require(ServerScriptService.Server.Classes.Battler)
local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local Deck = require(ServerScriptService.Server.Classes.Deck)
local DeckPlayerRandom = require(ServerScriptService.Server.Classes.DeckPlayerRandom)
local DeckService = require(ServerScriptService.Server.Services.DeckService)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponHelper = require(ReplicatedStorage.Shared.Util.WeaponHelper)
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)

local BattleSession = {}
BattleSession.__index = BattleSession

export type BattleSession = typeof(setmetatable({} :: {
	Player: Player,
	Battler: Battler.Battler,
	Animator: any,
	Model: Model,
}, BattleSession))

function BattleSession.new(args: {
	Player: Player,
	BattlerArgs: any,
	Root: BasePart,
	HoldPart: BasePart,
	Character: Model,
	Human: Humanoid,
	WeaponDef: any,
}): BattleSession
	local self = setmetatable({
		Player = args.Player,
		Battler = Battler.new(args.BattlerArgs),
		Trove = Trove.new(),
		WeaponDef = args.WeaponDef,
		AttackCooldown = Cooldown.new(args.WeaponDef.AttackCooldownTime),
	}, BattleSession)

	self.Animator = self.Trove:Construct(Animator, args.Human)
	self.Animator:Play(self.WeaponDef.Animations.Idle)

	self.Model = self.Trove:Add(WeaponHelper.attachModel(args.WeaponDef, args.Character, args.HoldPart))

	self.Trove:Add(self.Battler)

	self.Trove:AddPromise(PlayerLeaving(self.Player):andThenCall(self.Destroy, self))

	self.Trove:Connect(self.Battler.Destroyed, function()
		self:Destroy()
	end)

	self.Trove:Add(ActionService:Subscribe(self.Player, "Primary", function()
		self:Attack()
	end))

	local root = args.Root
	root.Anchored = true
	self.Trove:Add(function()
		root.Anchored = false
	end)

	return self
end

function BattleSession.promised(player: Player, position: number, direction: number)
	return Promise.new(function(resolve, reject, onCancel)
		local char = player.Character

		if not char then
			task.defer(function()
				player:LoadCharacter()
			end)
			player.CharacterAdded:Wait()
			if onCancel() then return end
		end

		while not char:IsDescendantOf(workspace) do
			task.wait()
			if onCancel() then return end
		end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then
			reject("Bad character")
			return
		end

		resolve(char, root)
	end):andThen(function(char, root)
		return Promise.new(function(resolve, reject, onCancel)
			local weaponId = WeaponService:GetEquippedWeapon(player):timeout(5):expect()
			if onCancel() then return end

			local def = WeaponDefs[weaponId]
			local holdPart = char:WaitForChild(def.HoldPartName, 5)
			local human = char:WaitForChild("Humanoid", 5)
			if onCancel() then return end

			if not (holdPart and human) then
				reject("Bad character")
				return
			end

			local deck = DeckService:GetDeckForBattle(player):expect()
			if onCancel() then return end

			local base = ReplicatedStorage.Assets.Models.Bases.Basic:Clone()

			resolve(BattleSession.new({
				Player = player,
				Root = root,
				HoldPart = holdPart,
				Character = char,
				Human = human,
				WeaponDef = def,
				BattlerArgs = {
					BaseModel = base,
					CharModel = char,
					Position = position,
					Direction = direction,
					TeamId = `PLAYER_{player.Name}`,
					DeckPlayer = DeckPlayerRandom.new(Deck.new(deck)),
					HealthMax = 100,
				},
			}))
		end)
	end)
end

function BattleSession.Attack(self: BattleSession)
	if not self.AttackCooldown:IsReady() then return end

	local battle = self.Battler:GetBattle()
	if not battle then return end
	if battle.State == "Ended" then return end

	local target = battle:TargetNearest({
		Position = self.Battler.Position,
		Range = math.huge,
		Filter = battle:DefaultFilter(self.Battler.TeamId),
	})

	if not target then return end

	local root = target:GetRoot()

	self.AttackCooldown:Use()

	self.Animator:Play(self.WeaponDef.Animations.Shoot, 0)

	local attackPromise = Promise.delay(0.05):andThen(function()
		local part = self.Model:FindFirstChild("Weapon")
		local here = part.Position
		local there = root.Position
		local start = CFrame.lookAt(here, there)

		EffectService:All(
			EffectProjectile({
				Model = ReplicatedStorage.Assets.Models.Arrow1,
				Start = start,
				Finish = root,
				Speed = 128,
			}),
			EffectSound({
				SoundId = PickRandom(self.WeaponDef.Sounds.Shoot),
				Target = part,
			})
		):andThen(function()
			target.Health:Adjust(-10)

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
		end)
	end)

	local cancelPromise = Promise.fromEvent(target.Destroyed):andThen(function()
		self.Animator:StopHard(self.WeaponDef.Animations.Shoot)
		self.AttackCooldown:Reset()
	end)

	return Promise.race({ attackPromise, cancelPromise })
end

function BattleSession.Destroy(self: BattleSession)
	self.Trove:Clean()
end

return BattleSession
