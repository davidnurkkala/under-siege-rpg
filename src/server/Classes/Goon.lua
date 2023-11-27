local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Health = require(ReplicatedStorage.Shared.Classes.Health)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Goon = {}
Goon.__index = Goon

export type Goon = typeof(setmetatable(
	{} :: {
		Position: number,
		Size: number,
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

local function createAnimator(root)
	local remote: RemoteEvent = root.Remote

	return Sift.Dictionary.map({ "Play", "Stop", "StopHard", "StopHardAll" }, function(funcName)
		return function(_, ...)
			remote:FireAllClients("Animator", funcName, ...)
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
	local animator = createAnimator(root)

	local self: Goon = setmetatable({
		Level = args.Level,
		Health = Health.new(args.Def.HealthMax(args.Level)),
		Position = args.Position,
		Direction = args.Direction,
		Root = root,
		Animator = animator,
		Size = args.Def.Size,
		TeamId = args.TeamId,
		Battle = args.Battle,
		Battler = args.Battler,
		Def = args.Def,
		Brain = args.Brain,
		Destroyed = Signal.new(),
		Remote = remote,
	}, Goon)

	self.Root.Parent = workspace

	self.Health:Observe(function(old, new)
		local change = new - old
		if change <= -0.25 then self.Brain:OnInjured() end

		remote:FireAllClients("Health", "Update", self.Health:GetMax(), self.Health:Get())
	end)

	self.Battle:Add(self)

	self.Brain:SetGoon(self)

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

function Goon.FromDef(self: Goon, key: string)
	return self.Def[key](self.Level)
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
	end

	self.Destroyed:Fire()
end

return Goon
