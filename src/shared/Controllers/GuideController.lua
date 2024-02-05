local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local Comm = require(ReplicatedStorage.Packages.Comm)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WorldDefs = require(ReplicatedStorage.Shared.Defs.WorldDefs)

local GuideController = {
	Priority = 0,
}

type GuideController = typeof(GuideController)

function GuideController.PrepareBlocking(self: GuideController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "GuideService")
	self.StatusRemote = self.Comm:GetProperty("Status")
	self.GuiGuideRemote = self.Comm:GetProperty("GuiGuide")

	self.Message = Property.new(nil, Sift.Dictionary.equalsDeep)
	self.Target = Property.new(nil)
	self.BeamEnabled = Property.new(true)

	self.StatusRemote:Observe(function(state)
		self:Update(state and state.state)
	end)

	self.Target:Observe(function(target)
		if not target then return end

		local trove = Trove.new()

		local beam = trove:Clone(ReplicatedStorage.Assets.Beams.DirectorBeam)

		local a0 = trove:Construct(Instance, "Attachment")
		trove:AddPromise(Promise.new(function(resolve, _, onCancel)
			local player = Players.LocalPlayer
			while not player.Character do
				task.wait()
				if onCancel() then return end
			end

			local char = player.Character
			if not char:IsDescendantOf(workspace) then
				task.wait()
				if onCancel() then return end
			end

			while not (char.PrimaryPart and char.PrimaryPart:IsDescendantOf(workspace)) do
				task.wait()
				if onCancel() then return end
			end

			resolve(char.PrimaryPart)
		end):andThen(function(root)
			a0.Parent = root
		end))

		local a1 = trove:Construct(Instance, "Attachment")
		if typeof(target) == "CFrame" then
			a1.Parent = workspace.Terrain
			a1.WorldPosition = target.Position
		elseif typeof(target) == "Instance" then
			if target:IsA("BasePart") then
				a1.Parent = target
				a1.WorldCFrame = target:GetPivot()
			elseif target:IsA("Model") then
				trove
					:AddPromise(Promise.new(function(resolve, _, onCancel)
						while target.PrimaryPart == nil do
							task.wait()
							if onCancel() then return end
						end
						resolve(target.PrimaryPart)
					end))
					:andThen(function(root)
						a1.Parent = root
						a1.WorldCFrame = target:GetPivot()
					end)
			end
		end

		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.Parent = workspace.Effects

		local function updateEnabled()
			beam.Enabled = self.BeamEnabled:Get() and (not BattleController.InBattle:Get())
		end

		trove:Add(self.BeamEnabled:Observe(updateEnabled))
		trove:Add(BattleController.InBattle:Observe(updateEnabled))

		return function()
			trove:Clean()
		end
	end)
end

function GuideController.ToggleBeam(self: GuideController)
	self.BeamEnabled:Set(not self.BeamEnabled:Get())
end

function GuideController.GetNearestTag(_self: GuideController, tag: string, predicate: ((any) -> boolean)?)
	local nearest = nil
	local bestDistance = math.huge

	for _, object: PVInstance in CollectionService:GetTagged(tag) do
		if not object:IsDescendantOf(workspace) then continue end
		if predicate and (not predicate(object)) then continue end

		local distance = Players.LocalPlayer:DistanceFromCharacter(object:GetPivot().Position)
		if distance < bestDistance then
			nearest = object
			bestDistance = distance
		end
	end

	return nearest
end

function GuideController.Update(self: GuideController, status)
	if status == nil then
		self.Message:Set(nil)
		self.Target:Set(nil)
	elseif status.Instruction == "TrainingDummy" then
		self.Message:Set({
			{ Desktop = "Hold left click", Mobile = "Tap and hold the attack button", Console = "Hold RT" },
			`to attack the dummy.\n{status.State.current // 1} / {status.State.required} Power`,
		})
		self.Target:Set(self:GetNearestTag("TrainingDummy"))
	elseif status.Instruction == "Gold" then
		self.Message:Set({
			`Defeat battlers and gain gold.\n{status.State.current // 1} / {status.State.required} Gold`,
		})
		self.Target:Set(nil)
	elseif status.Instruction == "Portal" then
		self.Message:Set({
			`Teleport to the {WorldDefs[status.State.worldId].Name}`,
		})
		self.Target:Set(self:GetNearestTag("WorldPortal"))
	elseif status.Instruction == "TrainLongTerm" then
		self.Message:Set({
			`Train, battle, hire soldiers, and become stronger.\n{status.State.current // 1} / {status.State.required} Power`,
		})
		self.Target:Set(nil)
	elseif status.Instruction == "WeaponShop" then
		self.Message:Set({
			`Unlock the {WeaponDefs[status.State.weaponId].Name} at the weapon shop.`,
		})

		self.Target:Set(self:GetNearestTag("WeaponShopZone"))
	elseif status.Instruction == "Battler" then
		self.Message:Set({
			`Battle the {BattlerDefs[status.State.battlerId].Name}.\n{status.State.victories} / {status.State.requirement} wins`,
		})

		self.Target:Set(self:GetNearestTag("BattlerPrompt", function(model)
			return model:GetAttribute("BattlerId") == status.State.battlerId
		end))
	end
end

return GuideController
