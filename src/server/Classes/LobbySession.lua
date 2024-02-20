local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EffectDizzy = require(ReplicatedStorage.Shared.Effects.EffectDizzy)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local MusicService = require(ServerScriptService.Server.Services.MusicService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WorldDefs = require(ReplicatedStorage.Shared.Defs.WorldDefs)
local WorldService = require(ServerScriptService.Server.Services.WorldService)

local LobbySessionUpdater = Updater.new()

local AutoRunTime = 2 / 3

local LobbySession = {}
LobbySession.__index = LobbySession

type LobbySession = typeof(setmetatable(
	{} :: {
		Player: Player,
		Trove: any,
		Character: Model,
		Root: BasePart,
		Animator: Animator.Animator,
		ActiveLockdown: any,
		Human: Humanoid,
		AutoRunTimer: number,
		IsWeaponEquipped: Property.Property,
	},
	LobbySession
))

function LobbySession.new(args: {
	Player: Player,
	Character: Model,
	Human: Humanoid,
}): LobbySession
	assert(LobbySessions.Get(args.Player) == nil, `Player already has a lobby session`)

	local trove = Trove.new()

	local animator = trove:Construct(Animator, args.Human)

	local self: LobbySession = setmetatable({
		Player = args.Player,
		Trove = trove,
		Character = args.Character,
		Root = args.Character.PrimaryPart,
		Human = args.Human,
		Animator = animator,
		Attacks = {},
		ActiveLockdown = nil,
		AutoRunTimer = 0,
		IsWeaponEquipped = Property.new(false),
	}, LobbySession)

	trove:AddPromise(PlayerLeaving(self.Player)):andThenCall(self.Destroy, self)

	trove:Add(DataService:ObserveKey(self.Player, "Deck", function(deck)
		local ids = Sift.Array.map(
			Sift.Array.sort(
				Sift.Array.filter(Sift.Set.toArray(deck.Equipped), function(cardId)
					local def = CardDefs[cardId]
					return def.Type == "Goon"
				end),
				function(idA, idB)
					local a, b = CardDefs[idA], CardDefs[idB]
					if a.Cost == b.Cost then
						return a.Id > b.Id
					else
						return a.Cost > b.Cost
					end
				end
			),
			function(cardId)
				local def = CardDefs[cardId]
				return def.GoonId
			end
		)

		self.Character:SetAttribute("EscortGoonIds", table.concat(Sift.Array.slice(ids, 1, 3), ","))

		return function()
			self.Character:SetAttribute("EscortGoonIds", nil)
		end
	end))

	self.Character:AddTag("GoonEscorted")
	trove:Add(function()
		self.Character:RemoveTag("GoonEscorted")
	end)

	self:SetUpWeapon()

	LobbySessionUpdater:Add(self)
	self.Trove:Add(function()
		LobbySessionUpdater:Remove(self)
	end)

	self.Human.MaxSlopeAngle = 55

	WorldService:GetCurrentWorld(self.Player):andThen(function(worldId)
		local def = WorldDefs[worldId]
		MusicService:SetSoundtrack(self.Player, def.Soundtrack)
	end)

	-- do last
	LobbySessions.Add(self.Player, self)
	trove:Add(function()
		LobbySessions.Remove(self.Player)
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
		return Promise.new(function(resolve, reject, onCancel)
			while not character:IsDescendantOf(workspace) do
				task.wait()
			end
			if onCancel() then return end

			local human = character:WaitForChild("Humanoid", 5)
			if onCancel() then return end

			if human == nil then
				reject("Bad character")
				return
			end

			resolve(LobbySession.new({
				Player = player,
				Character = character,
				Human = human,
			}))
		end)
	end, function() end)
end

function LobbySession.SetUpWeapon(self: LobbySession)
	self.Trove:Add(DataService:ObserveKey(self.Player, "Weapons", function(weapons)
		local def = WeaponDefs[weapons.Equipped]
		if not def then return end

		local holdPart = self.Character:FindFirstChild(def.HoldPartName)
		if not holdPart then return end

		local torso = self.Character:FindFirstChild("UpperTorso")
		if not torso then return end

		local trove = Trove.new()

		local model = trove:Clone(def.Model)
		local part = model.Weapon

		model.Parent = self.Character

		local size = part.Size
		local offset = CFrame.new(0, 0, torso.Size.Z / 2)
		if size.Z > size.X then
			offset *= CFrame.Angles(0, math.pi / 2, 0)
		end
		offset = CFrame.Angles(0, 0, math.pi / 4) * offset

		local weld = Instance.new("Weld")
		weld.Part0 = torso
		weld.Part1 = part
		weld.C0 = offset
		weld.Parent = model

		local grip = part.Grip
		grip.Enabled = false
		grip.Part0 = holdPart
		grip.Part1 = part

		trove:Add(self.IsWeaponEquipped:Observe(function(equipped)
			weld.Enabled = not equipped
			grip.Enabled = equipped

			if equipped then
				local idle = def.Animations.Idle
				self.Animator:Play(idle)

				return function()
					self.Animator:StopHard(idle)
				end
			end

			return
		end))

		return function()
			trove:Clean()
		end
	end))
end

function LobbySession.BeStunned(self: LobbySession)
	if self.ActiveLockdown then self.ActiveLockdown:cancel() end

	EffectService:All(EffectDizzy({
		Head = self.Character:FindFirstChild("Head") :: BasePart,
		Duration = 3,
	}))
	self.Animator:Play("Dizzy", 0)

	self.ActiveLockdown = Promise.delay(3):finally(function()
		self.Animator:StopHard("Dizzy")
		self.ActiveLockdown = nil
	end)
end

function LobbySession.LockDown(self: LobbySession, duration: number)
	self.ActiveLockdown = Promise.delay(duration):finally(function()
		self.ActiveLockdown = nil
	end)

	return self.ActiveLockdown
end

function LobbySession.Update(self: LobbySession, dt: number)
	local isMoving = self.Human.MoveDirection.Magnitude > 0.01
	if isMoving then
		self.AutoRunTimer = math.min(self.AutoRunTimer + dt, AutoRunTime)
	else
		self.AutoRunTimer = 0
	end
	local isRunning = self.AutoRunTimer >= AutoRunTime

	if self:IsLockedDown() then
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

function LobbySession.IsLockedDown(self: LobbySession)
	return self.ActiveLockdown ~= nil
end

function LobbySession.Destroy(self: LobbySession)
	self.Trove:Clean()
end

return LobbySession
