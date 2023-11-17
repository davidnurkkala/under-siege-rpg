local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local LoginStreakController = {
	Priority = 0,
}

type LoginStreakController = typeof(LoginStreakController)

function LoginStreakController.PrepareBlocking(self: LoginStreakController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "LoginStreakService")
	self.StatusRemote = self.Comm:GetProperty("Status")
end

return LoginStreakController
