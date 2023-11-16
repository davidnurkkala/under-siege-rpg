local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local Health = require(ReplicatedStorage.Shared.Classes.Health)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local GoonModel = {}
GoonModel.__index = GoonModel

export type GoonModel = typeof(setmetatable(
	{} :: {
		Model: Model,
		Root: Part,
		Trove: any,
		Animator: any,
		Guid: string,
		Health: any,
		OverheadPoint: Attachment,
	},
	GoonModel
))

local GoonUpdater = Updater.new()

function GoonModel.new(root): GoonModel
	local def = GoonDefs[root.Name]
	assert(def, `Missing def for goon model part {root.Name}`)

	local trove = Trove.new()

	local model = trove:Clone(def.Model)
	model.Parent = workspace

	local animator = trove:Construct(Animator, model.AnimationController)

	local self: GoonModel = setmetatable({
		Guid = Guid(),
		Root = root,
		Model = model,
		Trove = trove,
		Animator = animator,
		Health = Health.new(1),
		OverheadPoint = model.PrimaryPart.OverheadPoint,
	}, GoonModel)

	self.Root.Transparency = 1

	GoonUpdater:Add(self)
	trove:Add(function()
		GoonUpdater:Remove(self)
	end)

	trove
		:AddPromise(Promise.new(function(resolve, _, onCancel)
			while not root:FindFirstChild("Remote") do
				root.ChildAdded:Wait()
				if onCancel() then return end
			end
			resolve(root.Remote)
		end))
		:timeout(5)
		:andThen(function(remote)
			trove:Connect(remote.OnClientEvent, function(...)
				self:OnRemote(...)
			end)
		end)
		:catch(function() end)

	return self
end

function GoonModel.OnRemote(self: GoonModel, systemName, funcName, ...)
	if systemName == "Animator" then
		self.Animator[funcName](self.Animator, ...)
	elseif systemName == "Health" then
		if funcName == "Update" then self:UpdateHealth(...) end
	end
end

function GoonModel:UpdateHealth(max, amount)
	self.Health:SetMax(max)
	self.Health:Set(amount)
end

function GoonModel.Update(self: GoonModel, dt: number)
	local cframe = self.Root.CFrame * CFrame.new(0, -self.Root.Size.Y / 2, 0)
	self.Model:PivotTo(cframe)
end

function GoonModel.Destroy(self: GoonModel)
	self.Trove:Clean()
end

return GoonModel
