local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local ActionController = {
	Priority = 0,
}

type ActionController = typeof(ActionController)

local ActiveActions = {}

function ActionController.PrepareBlocking(self: ActionController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "ActionService")
	self.ActionStartedRemote = self.Comm:GetSignal("ActionStarted")
	self.ActionStoppedRemote = self.Comm:GetSignal("ActionStopped")

	ContextActionService:BindAction("Primary", function(_, state)
		if state == Enum.UserInputState.Begin then
			self:SetActionActive("Primary", true)
		elseif state == Enum.UserInputState.End then
			self:SetActionActive("Primary", false)
		end
	end, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then self:SetActionActive("Primary", false) end
		if input.KeyCode == Enum.KeyCode.ButtonR2 then self:SetActionActive("Primary", false) end
	end)

	UserInputService.TouchTapInWorld:Connect(function()
		self:SetActionActive("Primary", true)
	end)

	UserInputService.TouchEnded:Connect(function()
		self:SetActionActive("Primary", false)
	end)
end

function ActionController.SetActionActive(self: ActionController, actionName: string, active: boolean)
	if active then
		if ActiveActions[actionName] then return end

		ActiveActions[actionName] = true
		self.ActionStartedRemote:Fire(actionName)
	else
		if not ActiveActions[actionName] then return end

		ActiveActions[actionName] = nil
		self.ActionStoppedRemote:Fire(actionName)
	end
end

function ActionController.Once(self: ActionController, actionName: string)
	if ActiveActions[actionName] then return end

	self:SetActionActive(actionName, true)
	task.delay(0.05, function()
		self:SetActionActive(actionName, false)
	end)
end

return ActionController
