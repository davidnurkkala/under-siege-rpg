local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Trove = require(ReplicatedStorage.Packages.Trove)
local ActionServiceSubscription = {}
ActionServiceSubscription.__index = ActionServiceSubscription

type ActionServiceSubscription = typeof(setmetatable({} :: {
	Trove: any,
	Player: Player,
	ActionName: string,
	Active: boolean,
}, ActionServiceSubscription))

function ActionServiceSubscription.new(player: Player, actionName: string, callback: (number) -> (), actionService: any): ActionServiceSubscription
	local self: ActionServiceSubscription = setmetatable({
		Trove = Trove.new(),
		Player = player,
		ActionName = actionName,
		Active = false,
	}, ActionServiceSubscription)

	self:SetUpConnections(callback, actionService)

	return self
end

function ActionServiceSubscription.SetUpConnections(self: ActionServiceSubscription, callback, actionService: any)
	self.Trove:Connect(actionService.ActionStarted, function(player, actionName)
		if self.Active then return end
		if player ~= self.Player then return end
		if actionName ~= self.ActionName then return end

		self.Active = true

		local connection
		connection = RunService.Heartbeat:Connect(function(dt)
			if self.Active then
				callback(dt)
			else
				connection:Disconnect()
			end
		end)
	end)

	self.Trove:Connect(actionService.ActionStopped, function(player, actionName)
		if not self.Active then return end
		if player ~= self.Player then return end
		if actionName ~= self.ActionName then return end

		self.Active = false
	end)
end

function ActionServiceSubscription.Destroy(self: ActionServiceSubscription)
	self.Trove:Clean()
end

return ActionServiceSubscription
