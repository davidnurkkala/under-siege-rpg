local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local PowerController = {
	Priority = 0,
}

type PowerController = typeof(PowerController)

function PowerController.PrepareBlocking(self: PowerController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "PowerService")
	self.PowerRemote = self.Comm:GetProperty("Power")
	self.PrestigeCountRemote = self.Comm:GetProperty("PrestigeCount")
end

function PowerController.Start(self: PowerController) end

return PowerController
