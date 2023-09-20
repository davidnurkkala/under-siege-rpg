local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionService = require(ServerScriptService.Server.Services.ActionService)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectFaceTarget = require(ReplicatedStorage.Shared.Effects.EffectFaceTarget)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectShakeModel = require(ReplicatedStorage.Shared.Effects.EffectShakeModel)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local LevelService = require(ServerScriptService.Server.Services.LevelService)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local PlayAreaService = require(ServerScriptService.Server.Services.PlayAreaService)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
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
	local trove = Trove.new()

	local model = trove:Clone(args.WeaponDef.Model)
	do
		model.Parent = args.Character

		local part1 = model.Weapon
		local part0 = args.HoldPart
		local motor = part1.Grip
		motor.Part1 = part1
		motor.Part0 = part0
		motor.Enabled = true

		task.defer(function()
			print(motor.Parent)
			print(motor.Part1)
			print(motor.Part0)
		end)

		task.delay(1, function()
			print(motor.Parent)
			print(motor.Part1)
			print(motor.Part0)
			motor.Enabled = true
		end)
	end

	local animator = trove:Construct(Animator, args.Human)

	local self: LobbySession = setmetatable({
		Player = args.Player,
		Trove = trove,
		Character = args.Character,
		Model = model,
		Animator = animator,
		WeaponDef = args.WeaponDef,
	}, LobbySession)

	self.Animator:Play(self.WeaponDef.Animations.Idle)

	self.Trove:Connect(ActionService.ActionStarted, function(player, actionName)
		if player ~= self.Player then return end
		if actionName ~= "Primary" then return end

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

		-- temporary!!
		Promise.delay(0.05)
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
						Parent = part,
					})
				)
			end)
			:andThen(function()
				LevelService:AddExperience(self.Player, self.WeaponDef.Power)

				EffectService:All(
					EffectEmission({
						Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
						ParticleCount = 2,
						Target = dummy.Body.Core,
					}),
					EffectSound({
						SoundId = PickRandom(self.WeaponDef.Sounds.Hit),
						Parent = dummy.Body,
					}),
					EffectShakeModel({
						Model = dummy,
					})
				)
			end)
	end)

	return self
end

function LobbySession.promised(player: Player)
	return Promise.new(function(resolve)
		if player.Character then
			resolve(player.Character)
		else
			resolve(Promise.fromEvent(player.CharacterAdded):timeout(5))
		end
	end):andThen(function(character)
		return WeaponService:GetEquippedWeapon(player):andThen(function(weaponId)
			local def = WeaponDefs[weaponId]

			local holdPart = character:WaitForChild(def.HoldPartName, 5)
			local human = character:WaitForChild("Humanoid", 5)
			task.wait(1)
			if not (holdPart and human) then return Promise.reject("Bad character") end

			return LobbySession.new({
				Player = player,
				Character = character,
				WeaponDef = def,
				HoldPart = holdPart,
				Human = human,
			})
		end)
	end)
end

function LobbySession.Destroy(self: LobbySession)
	self.Trove:Clean()
end

return LobbySession
