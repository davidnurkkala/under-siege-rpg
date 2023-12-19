local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local LoginStreakController = {
	Priority = 0,
}

type LoginStreakController = typeof(LoginStreakController)

function LoginStreakController.PrepareBlocking(self: LoginStreakController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "LoginStreakService")
	self.StatusRemote = self.Comm:GetProperty("Status")
	self.ClaimRequestedRemote = self.Comm:GetSignal("ClaimRequested")
end

function LoginStreakController.ObserveStatus(self: LoginStreakController, callback)
	local connection = self.StatusRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

function LoginStreakController.Claim(self: LoginStreakController, index: number)
	self.ClaimRequestedRemote:Fire(index)
end

return LoginStreakController
