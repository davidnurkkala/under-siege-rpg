local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local QuestController = {
	Priority = 0,
}

type QuestController = typeof(QuestController)

function QuestController.PrepareBlocking(self: QuestController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "QuestService")
	self.QuestsRemote = self.Comm:GetProperty("Quests")
	self.TrackedIdRemote = self.Comm:GetProperty("TrackedId")
	self.TrackId = self.Comm:GetFunction("TrackId")
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
