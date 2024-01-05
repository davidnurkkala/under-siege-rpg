local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local Comm = require(ReplicatedStorage.Packages.Comm)
local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local EffectFadeModel = require(ReplicatedStorage.Shared.Effects.EffectFadeModel)
local EncounterDefs = require(ReplicatedStorage.Shared.Defs.EncounterDefs)
local EncounterHelper = require(ReplicatedStorage.Shared.Util.EncounterHelper)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
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
		HealthRemote: any,
		Model: Model?,
		Animator: Animator.Animator?,
		Active: boolean,
		State: any,
		Def: any,
		GoonDef: any,
		HealthPercent: any,
	},
	Encounter
))

local function stateToActive(state)
	return (state ~= EncounterHelper.State.Inactive) and (state ~= EncounterHelper.State.Dead)
end

function Encounter.new(part: BasePart): Encounter
	local encounterId = part:GetAttribute("EncounterId")
	assert(encounterId, `{part:GetFullName()} is an Encounter but has no EncounterId`)

	local def = EncounterDefs[encounterId]
	assert(def, `{encounterId} has no def`)

	local self: Encounter = setmetatable({
		Trove = Trove.new(),
		Root = part:WaitForChild("Root"),
		Active = false,
		State = EncounterHelper.State.Inactive,
		Def = def,
		GoonDef = GoonDefs[def.GoonId],
		HealthPercent = Property.new(1),
	}, Encounter)

	self.Trove:Add(self.HealthPercent)

	local comm = self.Trove:Construct(Comm.ClientComm, part, true, "Encounter")
	self.StateRemote = comm:GetProperty("State")
	self.HealthRemote = comm:GetProperty("Health")

	self.HealthRemote:Observe(function(healthPercent)
		self.HealthPercent:Set(healthPercent)
	end)

	self.HealthPercent:Observe(function(value)
		if self.Model then self.Model:SetAttribute("HealthPercent", value) end
	end)

	self.Trove:Add(self.StateRemote:Observe(function(...)
		self:OnStateChanged(...)
	end))

	return self
end

function Encounter.SetActive(self: Encounter, active: boolean)
	if active == self.Active then return end
	self.Active = active

	if self.Active then
		local model = self.GoonDef.Model:Clone() :: Model

		model:AddTag("EncounterModel")
		model:SetAttribute("HealthPercent", self.HealthPercent:Get())
		model:SetAttribute("Level", self.Def.Level)

		model.Parent = workspace
		self.Model = model

		-- fade in the model
		local fadePairs = Sift.Array.map(
			Sift.Array.filter(model:GetDescendants(), function(object)
				return object:IsA("BasePart")
			end),
			function(part)
				return { Part = part, Transparency = part.Transparency }
			end
		)
		Animate(0.5, function(scalar)
			for _, pair in fadePairs do
				pair.Part.Transparency = Lerp(1, pair.Transparency, scalar)
			end
		end)

		local animator = Animator.new(model.AnimationController)
		self.Animator = animator

		EncounterUpdater:Add(self)
	else
		local model = self.Model
		local animator = self.Animator
		EffectController:Effect(EffectFadeModel({
			Model = model,
			FadeTime = 0.5,
		})):andThen(function()
			model:Destroy()
			animator:Destroy()
		end)

		self.Model = nil
		self.Animator = nil

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
	self:SetActive(stateToActive(newState))
	if not self.Active then return end

	-- exiting old state
	if self.State == EncounterHelper.State.Walking then self:StopAnimation("Walk") end
	if self.State == EncounterHelper.State.Chasing then self:StopAnimation("Walk") end
	if self.State == EncounterHelper.State.Dying then self:StopAnimation("Die") end

	self.State = newState

	-- entering new state
	if self.State == EncounterHelper.State.Walking then self:PlayAnimation("Walk", 0) end
	if self.State == EncounterHelper.State.Chasing then self:PlayAnimation("Walk", 0, nil, 2) end
	if self.State == EncounterHelper.State.Attacking then self:PlayAnimation("Attack", 0, nil, nil, false) end
	if self.State == EncounterHelper.State.Dying then self:PlayAnimation("Die", 0) end
end

function Encounter.Destroy(self: Encounter)
	self.Trove:Clean()
end

return Encounter
