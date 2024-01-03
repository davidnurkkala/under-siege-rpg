local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local EncounterHelper = require(ReplicatedStorage.Shared.Util.EncounterHelper)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local ActivationRadius = 64
local ActivationWait = 3

local WalkSpeed = 8
local RunSpeed = 20

local AttackRange = 4.5

local EncounterUpdater = Updater.new()

local Encounter = {}
Encounter.__index = Encounter

export type Encounter = typeof(setmetatable(
	{} :: {
		Origin: CFrame,
		Radius: number,
		Trove: any,
		Active: boolean,
		StateRemote: any,
		Root: Attachment,
		Players: { [Player]: boolean },
		State: number,
		Destination: Vector3,
		Target: Player?,
		AttackWindup: number,
		AttackRest: number,
		GoonDef: any,
	},
	Encounter
))

local function createRoot(parent: BasePart)
	local attachment = Instance.new("Attachment")
	attachment.Name = "Root"
	attachment.Parent = parent
	return attachment
end

function Encounter.new(part: BasePart): Encounter
	local self: Encounter = setmetatable({
		Origin = part.CFrame,
		Radius = math.max(part.Size.X, part.Size.Z) / 2,
		Trove = Trove.new(),
		Active = false,
		Root = createRoot(part),
		Players = {},
		State = EncounterHelper.State.Inactive,
		Destination = Vector3.new(),
		Target = nil,
		AttackWindup = 0,
		AttackRest = 0,
		GoonDef = GoonDefs.Peasant, -- TODO: use actual data
	}, Encounter)

	local comm = self.Trove:Construct(Comm.ServerComm, part, "Encounter")
	self.StateRemote = comm:CreateProperty("State", EncounterHelper.State.Inactive)

	self.Trove:Add(task.spawn(function()
		while true do
			local newPlayers = Sift.Array.toSet(Sift.Array.filter(Players:GetPlayers(), function(player)
				return player:DistanceFromCharacter(self.Origin.Position) <= ActivationRadius
			end))

			-- clear data for removed players
			for player in self.Players do
				if not newPlayers[player] then self.StateRemote:ClearFor(player) end
			end

			-- replicate data for added players
			for player in newPlayers do
				if not self.Players[player] then self.StateRemote:SetFor(player, self.State) end
			end

			self.Players = newPlayers

			local hasPlayers = Sift.Set.count(self.Players) > 0
			if (self.State == EncounterHelper.State.Inactive) and hasPlayers then
				self:SetState(EncounterHelper.State.Idle)
			elseif (not hasPlayers) and (self.State ~= EncounterHelper.State.Inactive) then
				self:SetState(EncounterHelper.State.Inactive)
			end

			task.wait(ActivationWait)
		end
	end))

	return self
end

function Encounter.GetCFrame(self: Encounter)
	return self.Root.WorldCFrame
end

function Encounter.SetState(self: Encounter, state: number)
	if self.State == state then return end
	self.State = state

	self:SetActive(self.State ~= EncounterHelper.State.Inactive)
	self.StateRemote:SetForList(Sift.Set.toArray(self.Players), self.State)
end

function Encounter.SetActive(self: Encounter, active: boolean)
	if self.Active == active then return end
	self.Active = active

	if self.Active then
		EncounterUpdater:Add(self)
	else
		EncounterUpdater:Remove(self)
	end
end

function Encounter.GetRandomPosition(self: Encounter)
	local theta = math.random() * math.pi * 2
	local radius = math.random() * self.Radius
	return self.Origin:PointToWorldSpace(Vector3.new(math.cos(theta) * radius, 0, math.sin(theta) * radius))
end

function Encounter.GetPlayersInRange(self: Encounter)
	return Sift.Array.filter(Sift.Set.toArray(self.Players), function(player)
		return player:DistanceFromCharacter(self.Origin.Position) <= self.Radius
	end)
end

function Encounter.SeekTarget(self: Encounter)
	local players = self:GetPlayersInRange()
	if players[1] == nil then return end

	self.Target = players[math.random(1, #players)]
	self:SetState(EncounterHelper.State.Chasing)
end

function Encounter.MoveTowards(self: Encounter, position: Vector3, movement: number, arrivalDistance: number)
	local here = self.Root.WorldPosition
	local there = position
	local cframe = CFrame.lookAt(here, there)
	cframe *= CFrame.new(0, 0, -movement)
	self.Root.WorldCFrame = cframe

	local distance = (position - cframe.Position).Magnitude
	return distance <= arrivalDistance
end

function Encounter.FaceTowards(self: Encounter, position: Vector3)
	local here = self.Root.WorldPosition
	local there = position
	self.Root.WorldCFrame = CFrame.lookAt(here, there)
end

function Encounter.GetTargetPosition(self: Encounter)
	return TryNow(function()
		local target = self.Target :: Player
		local position = target.Character.PrimaryPart.Position
		position = Vector3.new(position.X, self.Origin.Y, position.Z)

		return position
	end, self.Origin.Position)
end

function Encounter.IsTargetValid(self: Encounter)
	return TryNow(function()
		local target = self.Target :: Player

		if not target.Parent then return false end
		if target:DistanceFromCharacter(self.Origin.Position) > self.Radius then return false end

		return true
	end, false)
end

function Encounter.Attack(self: Encounter)
	self:SetState(EncounterHelper.State.Attacking)
	self.AttackWindup = self.GoonDef.AttackWindupTime()
end

function Encounter.BeBlocked(self: Encounter, session)
	session.Animator:Play("Block", 0)

	local target = TryNow(function()
		return session.Character.PrimaryPart.RootAttachment
	end, Vector3.zero)

	EffectService:All(
		EffectEmission({
			Emitter = ReplicatedStorage.Assets.Emitters.DeflectEmitter1,
			ParticleCount = 1,
			Target = target,
		}),
		EffectEmission({
			Emitter = ReplicatedStorage.Assets.Emitters.Sparks1,
			ParticleCount = 16,
			Target = target,
		}),
		EffectSound({
			SoundId = "Block1",
			Target = target,
		})
	)
end

function Encounter.Update(self: Encounter, dt: number)
	if self.State == EncounterHelper.State.Idle then
		if math.random() < 0.05 then
			self.Destination = self:GetRandomPosition()
			self:SetState(EncounterHelper.State.Walking)
		end

		self:SeekTarget()
	elseif self.State == EncounterHelper.State.Walking then
		if self:MoveTowards(self.Destination, WalkSpeed * dt, 1) then
			self:SetState(EncounterHelper.State.Idle)
		else
			self:SeekTarget()
		end
	elseif self.State == EncounterHelper.State.Chasing then
		if not self:IsTargetValid() then
			self:SetState(EncounterHelper.State.Idle)
		elseif self:MoveTowards(self:GetTargetPosition(), RunSpeed * dt, AttackRange) then
			self:Attack()
		end
	elseif self.State == EncounterHelper.State.Attacking then
		if not self:IsTargetValid() then
			self:SetState(EncounterHelper.State.Idle)
			return
		end

		if self.AttackWindup > 0 then
			self:FaceTowards(self:GetTargetPosition())

			self.AttackWindup -= dt

			if self.AttackWindup <= 0 then
				Promise.try(function()
					local target = self.Target :: Player
					local root = target.Character.PrimaryPart :: BasePart
					local session = LobbySessions.Get(target)

					if session.AttackCooldown:IsReady() then
						self:BeBlocked(session)
					else
						session:BeStunned()

						EffectService:All(
							EffectSound({
								SoundId = PickRandom(self.GoonDef.Sounds.Hit),
								Target = root,
							}),
							EffectEmission({
								Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
								ParticleCount = 2,
								Target = root,
							})
						)
					end
				end):catch(warn)
				self.AttackRest = 3
			end
		elseif self.AttackRest > 0 then
			self.AttackRest -= dt

			if self.AttackRest <= 0 then self:SetState(EncounterHelper.State.Idle) end
		end
	end
end

function Encounter.Destroy(self: Encounter)
	self.Trove:Clean()
end

return Encounter
