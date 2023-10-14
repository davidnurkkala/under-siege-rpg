local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionServiceSubscription = require(ServerScriptService.Server.Classes.ActionServiceSubscription)
local Comm = require(ReplicatedStorage.Packages.Comm)
local Signal = require(ReplicatedStorage.Packages.Signal)

local ActionService = {
	Priority = 0,
	ActionStarted = Signal.new(),
	ActionStopped = Signal.new(),
}

type ActionService = typeof(ActionService)

function ActionService.PrepareBlocking(self: ActionService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "ActionService")
	self.ActionStartedRemote = self.Comm:CreateSignal("ActionStarted")
	self.ActionStoppedRemote = self.Comm:CreateSignal("ActionStopped")

	self.ActionStartedRemote:Connect(function(player, actionName)
		self.ActionStarted:Fire(player, actionName)
	end)

	self.ActionStoppedRemote:Connect(function(player, actionName)
		self.ActionStopped:Fire(player, actionName)
	end)
end

function ActionService.Start(self: ActionService) end

function ActionService.Subscribe(self: ActionService, player: Player, actionName: string, callback: (number) -> ())
	return ActionServiceSubscription.new(player, actionName, callback, self)
end

return ActionService
