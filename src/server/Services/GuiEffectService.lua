local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local GuiEffectService = {
	Priority = 0,
}

type GuiEffectService = typeof(GuiEffectService)

function GuiEffectService.PrepareBlocking(self: GuiEffectService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "GuiEffectService")
	self.IndicatorRequestedRemote = self.Comm:CreateSignal("IndicatorRequested")
	self.DamageNumberRequestedRemote = self.Comm:CreateSignal("DamageNumberRequested")
end

return GuiEffectService
