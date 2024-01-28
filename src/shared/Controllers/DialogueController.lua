local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DialogueController = {
	Priority = 0,
}

type DialogueController = typeof(DialogueController)

function DialogueController.PrepareBlocking(self: DialogueController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "DialogueService")
	self.StateRemote = self.Comm:GetProperty("State")
	self.InputChosen = self.Comm:GetSignal("InputChosen")
end

function DialogueController.ObserveState(self: DialogueController, callback)
	local connection = self.StateRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return DialogueController
