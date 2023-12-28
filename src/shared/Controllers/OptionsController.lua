local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local OptionsController = {
	Priority = 0,
}

type OptionsController = typeof(OptionsController)

function OptionsController.PrepareBlocking(self: OptionsController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "OptionsService")

	self.OptionsRemote = self.Comm:GetProperty("Options")
	self.SetOption = self.Comm:GetFunction("SetOption")
	self.GetOption = self.Comm:GetFunction("GetOption")
end

function OptionsController.ObserveOptions(self: OptionsController, callback)
	local connection = self.OptionsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return OptionsController
