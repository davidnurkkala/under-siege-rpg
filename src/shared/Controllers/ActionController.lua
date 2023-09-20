local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local ActionController = {
	Priority = 0,
}

type ActionController = typeof(ActionController)

function ActionController.PrepareBlocking(self: ActionController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "ActionService")
	self.ActionStartedRemote = self.Comm:GetSignal("ActionStarted")
	self.ActionStoppedRemote = self.Comm:GetSignal("ActionStopped")

	ContextActionService:BindAction("Primary", function(_, state)
		if state == Enum.UserInputState.Begin then
			self.ActionStartedRemote:Fire("Primary")
		elseif state == Enum.UserInputState.End then
			self.ActionStoppedRemote:Fire("Primary")
		end
	end, false, Enum.UserInputType.MouseButton1)
end

function ActionController.Start(self: ActionController) end

return ActionController
