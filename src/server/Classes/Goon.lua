local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BattleService = require(ServerScriptService.Server.Services.BattleService)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Health = require(ReplicatedStorage.Shared.Classes.Health)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Stat = require(ServerScriptService.Server.Classes.Stat)

local Rand = Random.new()

local Goon = {}
Goon.__index = Goon

export type Goon = typeof(setmetatable(
	{} :: {
		Position: number,
		TeamId: string,
		Direction: number,
		Health: Health.Health,
		Battle: any,
		Battler: any,
		Def: any,
		Animator: any,
		Destroyed: any,
		Level: number,
		Root: Part,
		Brain: any,
		Remote: RemoteEvent,
		Tags: { any },

		WillTakeDamage: any,
		DidTakeDamage: any,
		WillDealDamage: any,
		DidDealDamage: any,
		Died: any,

		Stats: { [string]: Stat.Stat },
	},
	Goon
))

local function createRoot(goonId)
	local root = Instance.new("Part")
	root.Name = goonId
	root.Anchored = true
	root.CanCollide = false
	root.CanTouch = false
	root.CanQuery = false
	root.Color = Color3.new(1, 0, 1)
	root.Size = Vector3.new(4, 5, 1)

	local remote = Instance.new("RemoteEvent")
	remote.Name = "Remote"
	remote.Parent = root

	CollectionService:AddTag(root, "GoonModel")

	return root, remote
end

local function fireRemote(remote, battle, ...)
	for _, player in BattleService:GetPlayersFromBattle(battle) do
		remote:FireClient(player, ...)
	end
end

local function createAnimator(remote, battle)
	return Sift.Dictionary.map({ "Play", "Stop", "StopHard", "StopHardAll" }, function(funcName)
		return function(_, ...)
			fireRemote(remote, battle, "Animator", funcName, ...)
		end, funcName
	end)
end

function Goon.new(args: {
	Position: number,
	Direction: number,
	TeamId: string,
	Def: any,
	Level: number,
	Battle: any,
	Battler: any,
	Brain: any,
}): Goon
	local root, remote = createRoot(args.Def.Id)
	local animator = createAnimator(remote, args.Battle)

	local self: Goon = setmetatable({
		Level = args.Level,
		Health = Health.new(args.Def.Stats.HealthMax(args.Level)),
		Position = args.Position,
		Direction = args.Direction,
		Root = root,
		Animator = animator,
		TeamId = args.TeamId,
		Battle = args.Battle,
		Battler = args.Battler,
		Def = args.Def,
		Brain = args.Brain,
		Destroyed = Signal.new(),
		Remote = remote,
		Tags = {},

		WillTakeDamage = Signal.new(),
		DidTakeDamage = Signal.new(),
		WillDealDamage = Signal.new(),
		DidDealDamage = Signal.new(),
		Died = Signal.new(),

		Stats = Sift.Dictionary.map(args.Def.Stats, function(value)
			return Stat.new(if typeof(value) == "function" then value(args.Level) else value)
		end),
	}, Goon)

	self.Root:SetAttribute("Level", self.Level)
	self.Root.Parent = self.Battle.Model

	self.Health:Observe(function(old, new)
		local change = new - old
		if change <= -0.25 then self.Brain:OnInjured() end

		fireRemote(self.Remote, self.Battle, "Health", "Update", self.Health:GetMax(), self.Health:Get())
	end)

	self.Battle:Add(self)
	self.Brain:SetGoon(self)

	if self.Def.Tags then
		self.Tags = Sift.Array.map(self.Def.Tags, function(tagId)
			local source = ServerScriptService.Server.Classes.GoonTags:FindFirstChild(`Tag{tagId}`)
			assert(source, `No tag implementation found for {tagId}`)
			local class = require(source)
			return class.new(self)
		end)
	end

	if self.Def.Animations and self.Def.Animations.Idle then self.Animator:Play(self.Def.Animations.Idle) end

	return self
end

function Goon.fromId(args: {
	Id: string,
	Position: number,
	Direction: number,
	TeamId: string,
	Battle: any,
	Battler: any,
	Level: number,
})
	local def = GoonDefs[args.Id]
	assert(def, `No def found for {args.Id}`)

	local brainId = def.Brain and def.Brain.Id
	assert(def, `Def {def.Id} has no brain`)

	local brainScript = ServerScriptService.Server.Classes.GoonBrains:FindFirstChild(brainId)
	assert(brainScript, `No brain script with name {brainId}`)

	local brainClass = require(brainScript)
	local brain = brainClass.new(def.Brain)

	return Goon.new(Sift.Dictionary.merge(args, {
		Brain = brain,
		Def = def,
	}))
end

function Goon.Is(object)
	return getmetatable(object) == Goon
end

function Goon.HasTag(self: Goon, tagId: string)
	if not self.Def.Tags then return false end

	return Sift.Array.has(self.Def.Tags, tagId)
end

function Goon.GetSize(self: Goon)
	return self:GetStat("Size")
end

function Goon.GetStat(self: Goon, name: string)
	return self.Stats[name]:Get()
end

function Goon.ModStat(self: Goon, name: string, numberName: string, modifier: (number) -> number)
	return self.Stats[name]:Modify(numberName, modifier)
end

function Goon.IsActive(self: Goon)
	return self.Health:Get() > 0
end

function Goon.Update(self: Goon, dt: number)
	self.Brain:Update(dt)

	self.Root:SetAttribute("Health", self.Health:Get())
	self.Root:SetAttribute("HealthMax", self.Health:GetMax())

	local position = self.Battle.Path:ToWorld(self.Position)
	local dy = CFrame.new(0, self.Root.Size.Y / 2, 0)
	self.Root.CFrame = CFrame.fromMatrix(position, if self.Direction < 0 then Vector3.zAxis else -Vector3.zAxis, Vector3.yAxis) * dy
end

function Goon.GetRoot(self: Goon): BasePart
	return self.Root
end

function Goon.GetWorldCFrame(self: Goon)
	return self:GetRoot().CFrame
end

function Goon.WhileAlive(self: Goon, promise)
	return Promise.race({
		Promise.fromEvent(self.Destroyed),
		promise,
	})
end

function Goon.VictoryAnimation(self: Goon)
	self.Animator:Play(self.Def.Animations.Victory or "GenericGoonCheer", nil, nil, Rand:NextNumber(0.8, 1.2))
end

function Goon.DefeatAnimation(self: Goon)
	self.Animator:Play(self.Def.Animations.Defeat or "GenericGoonDie")
end

function Goon.Destroy(self: Goon)
	self.Battle:Remove(self)

	if self.Health:Get() > 0 then
		self.Root:Destroy()
		self.Brain:Destroy()
	else
		self.Brain:OnDied():andThen(function()
			self.Root:Destroy()
			self.Brain:Destroy()
		end)

		self.Died:Fire()
	end

	for _, tag in self.Tags do
		tag:Destroy()
	end

	self.Destroyed:Fire()
end

return Goon
