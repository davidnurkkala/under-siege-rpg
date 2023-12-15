local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local Comm = require(ReplicatedStorage.Packages.Comm)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)

local TutorialController = {
	Priority = 0,
}

type TutorialController = typeof(TutorialController)

function TutorialController.PrepareBlocking(self: TutorialController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "TutorialService")
	self.StatusRemote = self.Comm:GetProperty("Status")
	self.Message = Property.new(nil, Sift.Dictionary.equalsDeep)
	self.Target = Property.new(nil)

	self.StatusRemote:Observe(function(state)
		self:Update(state and state.state)
	end)

	self.Target:Observe(function(target)
		if not target then return end

		local trove = Trove.new()

		local beam = trove:Clone(ReplicatedStorage.Assets.Beams.DirectorBeam)

		local a0 = trove:Construct(Instance, "Attachment")
		a0.Parent = Players.LocalPlayer.Character.PrimaryPart

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

		return function()
			trove:Clean()
		end
	end)
end

function TutorialController.GetNearestTag(_self: TutorialController, tag: string, predicate: ((any) -> boolean)?)
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

function TutorialController.Update(self: TutorialController, status)
	if status == nil then
		self.Message:Set(nil)
		self.Target:Set(nil)
	elseif status.Instruction == "TrainingDummy" then
		self.Message:Set({
			{ Desktop = "Click", Mobile = "Tap the attack button", Console = "RT" },
			`to attack the dummy.\n{status.State.current // 1} / {status.State.required} Power`,
		})

		self.Target:Set(self:GetNearestTag("TrainingDummy"))
	elseif status.Instruction == "WeaponShop" then
		self.Message:Set({
			`Unlock the {WeaponDefs[status.State.weaponId].Name} at the weapon shop.`,
		})

		self.Target:Set(self:GetNearestTag("WeaponShopZone"))
	elseif status.Instruction == "Battler" then
		self.Message:Set({
			`Battle the {BattlerDefs[status.State.battlerId].Name}.\n{status.State.victories} / {status.State.requirement} wins`,
		})

		self.Target:Set(self:GetNearestTag("BattlerPrompt"), function(model)
			return model:GetAttribute("BattlerId") == status.State.battlerId
		end)
	elseif status.Instruction == "CardGacha" then
		self.Message:Set({ `Hire a soldier.` })

		self.Target:Set(self:GetNearestTag("CardGachaZone"), function(model)
			return model:GetAttribute("GachaId") == "World1Soldiers"
		end)
	elseif status.Instruction == "PetGacha" then
		self.Message:Set({ `Hatch a pet.` })

		self.Target:Set(self:GetNearestTag("PetGachaZone"), function(model)
			return model:GetAttribute("GachaId") == "World1Soldiers"
		end)
	end
end

return TutorialController
