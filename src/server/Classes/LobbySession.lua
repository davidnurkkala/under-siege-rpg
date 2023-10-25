local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionService = require(ServerScriptService.Server.Services.ActionService)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectFaceTarget = require(ReplicatedStorage.Shared.Effects.EffectFaceTarget)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectShakeModel = require(ReplicatedStorage.Shared.Effects.EffectShakeModel)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local PlayAreaService = require(ServerScriptService.Server.Services.PlayAreaService)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local PowerService = require(ServerScriptService.Server.Services.PowerService)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponHelper = require(ReplicatedStorage.Shared.Util.WeaponHelper)
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)

local LobbySession = {}
LobbySession.__index = LobbySession

type LobbySession = typeof(setmetatable(
	{} :: {
		Player: Player,
		Trove: any,
		Character: Model,
		Model: Model,
		Animator: Animator.Animator,
		WeaponDef: any,
		AttackCooldown: Cooldown.Cooldown,
	},
	LobbySession
))

function LobbySession.new(args: {
	Player: Player,
	Character: Model,
	WeaponDef: any,
	HoldPart: BasePart,
	Human: Humanoid,
}): LobbySession
	assert(LobbySessions.Get(args.Player) == nil, `Player already has a lobby session`)

	local trove = Trove.new()

	local model = trove:Add(WeaponHelper.attachModel(args.WeaponDef, args.Character, args.HoldPart))
	local animator = trove:Construct(Animator, args.Human)

	local self: LobbySession = setmetatable({
		Player = args.Player,
		Trove = trove,
		Character = args.Character,
		Model = model,
		Animator = animator,
		WeaponDef = args.WeaponDef,
		AttackCooldown = Cooldown.new(args.WeaponDef.AttackCooldownTime),
	}, LobbySession)

	-- TODO: link up to a spawn zone?
	self.Character:MoveTo(Vector3.new(0, 16, 0))

	self.Animator:Play(self.WeaponDef.Animations.Idle)

	trove:Add(ActionService:Subscribe(self.Player, "Primary", function()
		self:Attack()
	end))

	LobbySessions.Add(self.Player, self)
	trove:Add(function()
		LobbySessions.Remove(self.Player)
	end)

	trove:AddPromise(PlayerLeaving(self.Player):andThenCall(self.Destroy, self))

	return self
end

function LobbySession.promised(player: Player)
	return Promise.new(function(resolve, reject)
		if LobbySessions.Get(player) then
			reject("Player already has a lobby session")
			return
		end

		if player.Character then
			resolve(player.Character)
		else
			Promise.defer(function()
				player:LoadCharacter()
			end):catch(function() end)

			resolve(Promise.fromEvent(player.CharacterAdded):timeout(5))
		end
	end):andThen(function(character)
		return WeaponService:GetEquippedWeapon(player):andThen(function(weaponId)
			return Promise.new(function(resolve, reject, onCancel)
				local def = WeaponDefs[weaponId]

				while not character:IsDescendantOf(workspace) do
					task.wait()
				end

				if onCancel() then return end

				local holdPart = character:WaitForChild(def.HoldPartName, 5)
				local human = character:WaitForChild("Humanoid", 5)

				if onCancel() then return end

				if not (holdPart and human) then
					reject("Bad character")
					return
				end

				while not holdPart:IsDescendantOf(workspace) do
					task.wait()
				end

				if onCancel() then return end

				resolve(LobbySession.new({
					Player = player,
					Character = character,
					WeaponDef = def,
					HoldPart = holdPart,
					Human = human,
				}))
			end)
		end)
	end, function() end)
end

function LobbySession.Attack(self: LobbySession)
	if not self.AttackCooldown:IsReady() then return end
	self.AttackCooldown:Use()

	self.Animator:Play(self.WeaponDef.Animations.Shoot, 0)

	local dummy = PlayAreaService:GetTrainingDummy()

	EffectService:Effect(
		self.Player,
		EffectFaceTarget({
			Root = self.Character.PrimaryPart,
			Target = dummy,
			Duration = 0.25,
		})
	)

	return Promise.delay(0.05)
		:andThen(function()
			local part = self.Model:FindFirstChild("Weapon")
			local here = part.Position
			local there = dummy.Body.Core.WorldPosition
			local start = CFrame.lookAt(here, there)
			local finish = start - here + there

			return EffectService:All(
				EffectProjectile({
					Model = ReplicatedStorage.Assets.Models.Arrow1,
					Start = start,
					Finish = finish,
					Speed = 128,
				}),
				EffectSound({
					SoundId = PickRandom(self.WeaponDef.Sounds.Shoot),
					Target = part,
				})
			)
		end)
		:andThen(function()
			PowerService:AddPower(self.Player, self.WeaponDef.Power)

			EffectService:All(
				EffectEmission({
					Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
					ParticleCount = 2,
					Target = dummy.Body.Core,
				}),
				EffectSound({
					SoundId = PickRandom(self.WeaponDef.Sounds.Hit),
					Target = dummy.Body,
				}),
				EffectShakeModel({
					Model = dummy,
				})
			)
		end)
end

function LobbySession.Destroy(self: LobbySession)
	self.Trove:Clean()
end

return LobbySession
