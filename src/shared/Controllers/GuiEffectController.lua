local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local GuiEffectController = {
	Priority = 0,
}

type GuiEffectController = typeof(GuiEffectController)

function GuiEffectController.PrepareBlocking(self: GuiEffectController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "GuiEffectService")
	self.IndicatorRequestedRemote = self.Comm:GetSignal("IndicatorRequested")
end

return GuiEffectController
