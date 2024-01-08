local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local QuestController = {
	Priority = 0,
}

type QuestController = typeof(QuestController)

function QuestController.PrepareBlocking(self: QuestController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "QuestService")
	self.QuestsRemote = self.Comm:GetProperty("Quests")
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
