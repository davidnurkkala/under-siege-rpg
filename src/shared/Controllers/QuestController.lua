local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local QuestController = {
	Priority = 0,
}

type QuestController = typeof(QuestController)

function QuestController.PrepareBlocking(self: QuestController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "QuestService")
	self.QuestsRemote = self.Comm:GetProperty("Quests")
	self.TrackedIdRemote = self.Comm:GetProperty("TrackedId")
	self.TrackId = self.Comm:GetFunction("TrackId")

	self.Quests = Property.new(nil, Sift.Dictionary.equalsDeep)
	self:ObserveQuests(function(value)
		self.Quests:Set(value)
	end)

	self.TrackedId = Property.new(nil)
	self:ObserveTrackedId(function(value)
		self.TrackedId:Set(value)
	end)

	self:SetUpDirectorBeam()
end

function QuestController.SetUpDirectorBeam(self: QuestController)
	self.Quests:Observe(function(quests)
		if quests == nil then return end

		return self.TrackedId:Observe(function(trackedId)
			if trackedId == nil then return end

			local quest = quests[trackedId]
			local target = quest and quest.Target
			if target == nil then return end

			return Observers.observeCharacter(function(player, character)
				if player ~= Players.LocalPlayer then return end

				local trove = Trove.new()

				trove
					:AddPromise(Promise.new(function(resolve, _, onCancel)
						while not character:IsDescendantOf(workspace) do
							task.wait()
							if onCancel() then return end
						end

						while not character.PrimaryPart do
							task.wait()
							if onCancel() then return end
						end

						while not character.PrimaryPart:IsDescendantOf(workspace) do
							task.wait()
							if onCancel() then return end
						end

						resolve(character.PrimaryPart)
					end))
					:andThen(function(root)
						local a0 = trove:Construct(Instance, "Attachment")
						a0.Parent = root

						local a1 = trove:Construct(Instance, "Attachment")
						if typeof(target) == "Instance" then
							if target:IsA("Model") then
								a1.Parent = target.PrimaryPart
							elseif target:IsA("BasePart") then
								a1.Parent = target
							end
						elseif typeof(target) == "Vector3" then
							a1.Parent = workspace.Terrain
							a1.WorldPosition = target
						elseif typeof(target) == "CFrame" then
							a1.Parent = workspace.Terrain
							a1.WorldCFrame = target
						end

						local beam = trove:Clone(ReplicatedStorage.Assets.Beams.DirectorBeam)
						beam.Attachment0 = a0
						beam.Attachment1 = a1
						beam.Parent = root
					end)

				return function()
					trove:Clean()
				end
			end)
		end)
	end)
end

function QuestController.ObserveTrackedId(self: QuestController, callback)
	local connection = self.TrackedIdRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

function QuestController.ObserveQuests(self: QuestController, callback)
	local connection = self.QuestsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

function QuestController.IsQuestComplete(self: QuestController, questId: string)
	local quests = self.QuestsRemote:Get()
	if not quests then return false end

	return quests[questId] == "Complete"
end

return QuestController
