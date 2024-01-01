local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local Comm = require(ReplicatedStorage.Packages.Comm)
local EncounterHelper = require(ReplicatedStorage.Shared.Util.EncounterHelper)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local EncounterUpdater = Updater.new()

local Encounter = {}
Encounter.__index = Encounter

export type Encounter = typeof(setmetatable(
	{} :: {
		Trove: any,
		Root: Attachment,
		StateRemote: any,
		Model: Model?,
		Animator: Animator.Animator?,
		Active: boolean,
		State: any,
		GoonDef: any,
	},
	Encounter
))

function Encounter.new(part): Encounter
	local self: Encounter = setmetatable({
		Trove = Trove.new(),
		Root = part:WaitForChild("Root"),
		Active = false,
		State = EncounterHelper.State.Inactive,
		GoonDef = GoonDefs.Peasant, -- TODO: use something else
	}, Encounter)

	local comm = self.Trove:Construct(Comm.ClientComm, part, true, "Encounter")
	self.StateRemote = comm:GetProperty("State")

	self.Trove:Add(self.StateRemote:Observe(function(...)
		self:OnStateChanged(...)
	end))

	return self
end

function Encounter.SetActive(self: Encounter, active: boolean)
	if active == self.Active then return end
	self.Active = active

	if self.Active then
		local model = self.GoonDef.Model:Clone()
		model.Parent = workspace
		self.Model = model

		local animator = Animator.new(model.AnimationController)
		self.Animator = animator

		EncounterUpdater:Add(self)
	else
		(self.Model :: Model):Destroy();
		(self.Animator :: Animator.Animator):Destroy()

		EncounterUpdater:Remove(self)
	end
end

function Encounter.Update(self: Encounter, dt: number)
	local model = self.Model :: Model
	model:PivotTo(self.Root.WorldCFrame)
end

function Encounter:PlayAnimation(animName: string, ...)
	(self.Animator :: Animator.Animator):Play(self.GoonDef.Animations[animName], ...)
end

function Encounter:StopAnimation(animName: string)
	(self.Animator :: Animator.Animator):StopHard(self.GoonDef.Animations[animName])
end

function Encounter.OnStateChanged(self: Encounter, newState)
	self:SetActive(newState ~= EncounterHelper.State.Inactive)

	-- exiting old state
	if self.State == EncounterHelper.State.Walking then self:StopAnimation("Walk") end
	if self.State == EncounterHelper.State.Chasing then self:StopAnimation("Walk") end

	self.State = newState

	-- entering new state
	if self.State == EncounterHelper.State.Walking then self:PlayAnimation("Walk", 0) end
	if self.State == EncounterHelper.State.Chasing then self:PlayAnimation("Walk", 0, nil, 2) end
	if self.State == EncounterHelper.State.Attacking then self:PlayAnimation("Attack", 0, nil, nil, false) end
end

function Encounter.Destroy(self: Encounter)
	self.Trove:Clean()
end

return Encounter
