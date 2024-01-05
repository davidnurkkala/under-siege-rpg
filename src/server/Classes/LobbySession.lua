local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionService = require(ServerScriptService.Server.Services.ActionService)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local ComponentService = require(ServerScriptService.Server.Services.ComponentService)
local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EffectDizzy = require(ReplicatedStorage.Shared.Effects.EffectDizzy)
local EffectFaceTarget = require(ReplicatedStorage.Shared.Effects.EffectFaceTarget)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Pet = require(ServerScriptService.Server.Classes.Pet)
local PetHelper = require(ReplicatedStorage.Shared.Util.PetHelper)
local PetService = require(ServerScriptService.Server.Services.PetService)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local ProductHelper = require(ReplicatedStorage.Shared.Util.ProductHelper)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponHelper = require(ReplicatedStorage.Shared.Util.WeaponHelper)
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)

local LobbySessionUpdater = Updater.new()

local AutoRunTime = 2 / 3

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
		Attacks: any,
		ActiveStun: any,
		Human: Humanoid,
		AutoRunTimer: number,
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

	local model = WeaponHelper.attachModel(args.WeaponDef, args.Character, args.HoldPart)
	local animator = trove:Construct(Animator, args.Human)

	local self: LobbySession = setmetatable({
		Player = args.Player,
		Trove = trove,
		Character = args.Character,
		Human = args.Human,
		Model = model,
		Animator = animator,
		WeaponDef = args.WeaponDef,
		AttackCooldown = Cooldown.new(args.WeaponDef.AttackCooldownTime),
		Attacks = {},
		ActiveStun = nil,
		AutoRunTimer = 0,
	}, LobbySession)

	self.Animator:Play(self.WeaponDef.Animations.Idle)

	trove:Add(function()
		if self.Model then self.Model:Destroy() end
	end)

	trove:Add(ActionService:Subscribe(self.Player, "Primary", function()
		self:Attack()
	end))

	LobbySessions.Add(self.Player, self)
	trove:Add(function()
		LobbySessions.Remove(self.Player)
	end)

	trove:AddPromise(PlayerLeaving(self.Player):andThenCall(self.Destroy, self))

	trove:Add(DataService:ObserveKey(self.Player, "Weapons", function(weapons)
		if weapons.Equipped == self.WeaponDef.Id then return end

		self:SetWeapon(WeaponDefs[weapons.Equipped])
	end))

	trove:Add(DataService:ObserveKey(self.Player, "Pets", function(pets)
		local equipped = Sift.Dictionary.keys(pets.Equipped)
		if #equipped == 0 then return end

		local root = self.Character.PrimaryPart
		if not root then return end

		local petTrove = Trove.new()

		local number = 0
		local radius = 5
		for hash, count in pets.Equipped do
			for _ = 1, count do
				local petId = PetHelper.HashToInfo(hash)

				local angle = math.rad(30) + math.rad(60) * number
				local dx = math.cos(angle) * radius
				local dz = math.sin(angle) * radius
				local cframe = root.CFrame * CFrame.new(dx, -1.5, dz)

				petTrove:Construct(Pet, petId, root, args.Human, cframe)

				number += 1
			end
		end

		return function()
			petTrove:Clean()
		end
	end))

	LobbySessionUpdater:Add(self)
	self.Trove:Add(function()
		LobbySessionUpdater:Remove(self)
	end)

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

function LobbySession.BeStunned(self: LobbySession)
	if self.ActiveStun then self.ActiveStun:cancel() end

	EffectService:All(EffectDizzy({
		Head = self.Character:FindFirstChild("Head") :: BasePart,
		Duration = 3,
	}))
	self.Animator:Play("Dizzy", 0)

	self.ActiveStun = Promise.delay(3):finally(function()
		self.Animator:StopHard("Dizzy")
		self.ActiveStun = nil
	end)
end

function LobbySession.Update(self: LobbySession, dt: number)
	local isMoving = self.Human.MoveDirection.Magnitude > 0.01
	if isMoving then
		self.AutoRunTimer = math.min(self.AutoRunTimer + dt, AutoRunTime)
	else
		self.AutoRunTimer = 0
	end
	local isRunning = self.AutoRunTimer >= AutoRunTime

	if self:IsStunned() then
		self.AutoRunTimer = 0
		self.Human.WalkSpeed = 0
	else
		if isRunning then
			self.Human.WalkSpeed = 28
		else
			self.Human.WalkSpeed = 16
		end
	end
end

function LobbySession.IsStunned(self: LobbySession)
	return self.ActiveStun ~= nil
end

function LobbySession.SetWeapon(self: LobbySession, weaponDef)
	return Promise.try(function()
		local holdPart = self.Character:FindFirstChild(weaponDef.HoldPartName)
		return WeaponHelper.attachModel(weaponDef, self.Character, holdPart)
	end):andThen(function(model)
		self.WeaponDef = weaponDef

		self.Model:Destroy()
		self.Model = model

		self.Animator:StopHardAll()
		self.Animator:Play(weaponDef.Animations.Idle)
	end)
end

function LobbySession.GetClosestDummy(self: LobbySession)
	local bestDummy = nil
	local bestDistance = math.huge

	local root = self.Character.PrimaryPart
	local here = TryNow(function()
		return root.Position
	end, Vector3.zero)

	for _, dummy in ComponentService:GetComponentsByName("TrainingDummy") do
		if ProductHelper.IsVip(self.Player) then
			if not dummy.IsPremium then continue end
		else
			if dummy.IsPremium then continue end
		end

		local there = dummy:GetPosition()
		local distance = (there - here).Magnitude
		if distance <= bestDistance then
			bestDummy = dummy
			bestDistance = distance
		end
	end

	return bestDummy
end

function LobbySession.GetClosestEncounter(self: LobbySession)
	local bestEncounter = nil
	local bestDistance = math.huge

	local root = self.Character.PrimaryPart
	local here = TryNow(function()
		return root.Position
	end, Vector3.zero)

	for _, encounter in ComponentService:GetComponentsByName("Encounter") do
		if not encounter:IsAlive() then continue end

		local there = encounter.Origin.Position
		local distance = (there - here).Magnitude
		if distance > encounter.Radius then continue end
		if distance < bestDistance then
			bestDistance = distance
			bestEncounter = encounter
		end
	end

	return bestEncounter
end

function LobbySession.Attack(self: LobbySession)
	if self:IsStunned() then return end

	if not self.AttackCooldown:IsReady() then return end
	self.AttackCooldown:Use()

	self.Animator:Play(self.WeaponDef.Animations.Shoot, 0)

	local encounter = self:GetClosestEncounter()
	local dummy = self:GetClosestDummy()

	local target = if encounter then encounter else dummy
	local there = target:GetPosition()

	EffectService:Effect(
		self.Player,
		EffectFaceTarget({
			Root = self.Character.PrimaryPart,
			Target = there,
			Duration = 0.25,
		})
	)

	local attack = Promise.delay(0.05)
		:andThen(function()
			local part = self.Model:FindFirstChild("Weapon")
			if not part then return Promise.reject("No weapon") end

			local here = part.Position
			local start = CFrame.lookAt(here, there)
			local finish = start - here + there

			return EffectService:All(
				EffectProjectile({
					Model = ReplicatedStorage.Assets.Models.Projectiles[self.WeaponDef.ProjectileName],
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
			return PetService:GetPets(self.Player)
		end)
		:andThen(function(pets)
			local multiplier = PetHelper.GetTotalPower(pets)

			if encounter then
				multiplier += 1.25
			end

			if ProductHelper.IsVip(self.Player) then
				multiplier *= 1.25
			end

			return CurrencyService:GetBoosted(self.Player, "Primary", self.WeaponDef.Power * multiplier)
		end)
		:andThen(function(amountAdded)
			GuiEffectService.IndicatorRequestedRemote:Fire(self.Player, {
				Text = `+{amountAdded // 0.1 / 10}`,
				Image = CurrencyDefs.Primary.Image,
				Start = there,
				EndGui = "GuiPanelPrimary",
			})

			if encounter then
				encounter:GetHit(self.Player, PickRandom(self.WeaponDef.Sounds.Hit))
			else
				dummy:HitEffect(PickRandom(self.WeaponDef.Sounds.Hit))
			end

			return Promise.delay(0.5):andThenReturn(amountAdded)
		end)
		:andThen(function(amountAdded)
			CurrencyService:AddCurrency(self.Player, "Primary", amountAdded)
		end)
		:catch(warn)

	self.Attacks[attack] = true
	attack:finally(function()
		self.Attacks[attack] = nil
	end)

	return attack
end

function LobbySession.CancelAttacks(self: LobbySession)
	for attack in self.Attacks do
		attack:cancel()
	end
	self.Attacks = {}
end

function LobbySession.Destroy(self: LobbySession)
	self.Trove:Clean()
end

return LobbySession
