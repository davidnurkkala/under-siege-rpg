local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local EffectController = {
	Priority = 0,
}

type EffectController = typeof(EffectController)

function EffectController.PrepareBlocking(self: EffectController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "EffectService")
	self.EffectRequested = self.Comm:GetSignal("EffectRequested")

	self.EffectRequested:Connect(function(name: string, args: { [string]: any })
		local moduleScript = ReplicatedStorage.Shared.Effects:FindFirstChild(name)
		assert(moduleScript, `Could not find effect with name {name}`)

		local effect = require(moduleScript)

		self:Effect(effect(args))
	end)
end

function EffectController.Effect(self: EffectController, _serverImpl, clientImpl)
	return clientImpl()
end

function EffectController.Start(self: EffectController) end

return EffectController
