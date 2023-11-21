local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionService = require(ServerScriptService.Server.Services.ActionService)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local ComponentService = require(ServerScriptService.Server.Services.ComponentService)
local Cooldown = require(ReplicatedStorage.Shared.Classes.Cooldown)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EffectFaceTarget = require(ReplicatedStorage.Shared.Effects.EffectFaceTarget)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetHelper = require(ReplicatedStorage.Shared.Util.PetHelper)
local PetService = require(ServerScriptService.Server.Services.PetService)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
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

	local model = WeaponHelper.attachModel(args.WeaponDef, args.Character, args.HoldPart)
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
		for slotId in pets.Equipped do
			local slot = pets.Owned[slotId]
			local petDef = PetDefs[slot.PetId]

			local angle = math.rad(30) + math.rad(60) * number
			local dx = math.cos(angle) * radius
			local dz = math.sin(angle) * radius
			local cframe = root.CFrame * CFrame.new(dx, -1.5, dz)

			local pet = petTrove:Clone(petDef.Model)
			pet:PivotTo(cframe)
			pet.Parent = self.Character

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = pet.PrimaryPart
			weld.Parent = pet.PrimaryPart

			number += 1
		end

		return function()
			petTrove:Clean()
		end
	end))

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

function LobbySession.Attack(self: LobbySession)
	if not self.AttackCooldown:IsReady() then return end
	self.AttackCooldown:Use()

	self.Animator:Play(self.WeaponDef.Animations.Shoot, 0)

	local dummy = Sift.Dictionary.values(ComponentService:GetComponentsByName("TrainingDummy"))[1]
	local there = dummy:GetPosition()

	EffectService:Effect(
		self.Player,
		EffectFaceTarget({
			Root = self.Character.PrimaryPart,
			Target = dummy.Model,
			Duration = 0.25,
		})
	)

	return Promise.delay(0.05)
		:andThen(function()
			local part = self.Model:FindFirstChild("Weapon")
			local here = part.Position
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
			return PetService:GetPets(self.Player)
		end)
		:andThen(function(pets)
			local multiplier = PetHelper.GetTotalPower(pets)
			local amountAdded = self.WeaponDef.Power * multiplier

			GuiEffectService.IndicatorRequestedRemote:Fire(self.Player, {
				Text = `+{amountAdded // 0.1 / 10}`,
				Image = CurrencyDefs.Primary.Image,
				Start = there,
				EndGui = "GuiPanelPrimary",
			})

			dummy:HitEffect(PickRandom(self.WeaponDef.Sounds.Hit))

			return Promise.delay(0.5):andThenReturn(amountAdded)
		end)
		:andThen(function(amountAdded)
			CurrencyService:AddCurrency(self.Player, "Primary", amountAdded)
		end)
end

function LobbySession.Destroy(self: LobbySession)
	self.Trove:Clean()
end

return LobbySession
