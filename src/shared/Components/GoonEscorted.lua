local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local CutsceneController = require(ReplicatedStorage.Shared.Controllers.CutsceneController)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local GoonEscortedUpdater = Updater.new()

local OffsetByIndex = {
	CFrame.new(0, 0, 4),
	CFrame.new(-3, 0, 1.5),
	CFrame.new(3, 0, 1.5),
}

local Speed = 30

local GoonEscorted = {}
GoonEscorted.__index = GoonEscorted

type Goon = {
	Model: Model,
	Animator: Animator.Animator,
	AnimationId: string,
}

export type GoonEscorted = typeof(setmetatable(
	{} :: {
		Model: Model,
		Root: BasePart,
		GoonIds: Property.Property,
		Trove: any,
		Goons: { Goon },
	},
	GoonEscorted
))

function GoonEscorted.new(model: Model): GoonEscorted
	local trove = Trove.new()

	local self: GoonEscorted = setmetatable({
		Model = model,
		Root = model.PrimaryPart,
		GoonIds = trove:Construct(Property, {}),
		Goons = {},
		Trove = trove,
	}, GoonEscorted)

	trove:Add(Observers.observeAttribute(self.Model, "EscortGoonIds", function(ids)
		if ids == "" then
			self.GoonIds:Set({})
		else
			self.GoonIds:Set(string.split(ids, ","))
		end
	end))

	self.GoonIds:Observe(function(goonIds)
		self.Goons = Sift.Array.map(goonIds, function(goonId)
			local def = GoonDefs[goonId]

			local goonModel = def.Model:Clone()
			goonModel:ScaleTo(0.75)
			goonModel.Parent = workspace.Effects

			local animator = Animator.new(goonModel.AnimationController)

			return {
				Model = goonModel,
				Animator = animator,
				AnimationId = def.Animations.Walk,
			}
		end)

		return function()
			for _, goon in self.Goons do
				goon.Animator:Destroy()
				goon.Model:Destroy()
			end
		end
	end)

	GoonEscortedUpdater:Add(self)
	trove:Add(function()
		GoonEscortedUpdater:Remove(self)
	end)

	return self
end

function GoonEscorted.Update(self: GoonEscorted, dt: number)
	if CutsceneController.InCutscene:Get() then return end
	if not self.Root then return end

	local filter = Sift.Array.append(
		Sift.Array.map(self.Goons, function(goon)
			return goon.Model
		end),
		self.Model
	)

	for index, goon in self.Goons do
		local cframe = self.Root.CFrame * OffsetByIndex[index]

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = filter

		local result1 = workspace:Raycast(self.Root.Position, cframe.Position - self.Root.Position, params)
		local result2 = workspace:Raycast(cframe.Position, Vector3.yAxis * -1024, params)
		local point = if result1 then result1.Position else if result2 then result2.Position else cframe.Position

		local here = goon.Model:GetPivot().Position
		local delta = point - here
		local distance = delta.Magnitude

		if distance < 0.1 then
			goon.Animator:StopHardAll()
			continue
		end

		goon.Animator:Play(goon.AnimationId, 0)

		local traversed = math.min(Speed * dt, distance)
		if distance > 32 then traversed = distance end

		local newPosition = here + (delta / distance) * traversed

		local flat = delta * Vector3.new(1, 0, 1)
		if flat:FuzzyEq(Vector3.zero, 0.01) then flat = self.Root.CFrame.LookVector end

		goon.Model:PivotTo(CFrame.lookAlong(newPosition, flat))
	end
end

function GoonEscorted.Destroy(self: GoonEscorted)
	self.Trove:Clean()
end

return GoonEscorted
