local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Promise = require(ReplicatedStorage.Packages.Promise)

local EffectController = {
	Priority = 0,
	Persistents = {},
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

function EffectController.Persist(self: EffectController, guid: string, handler: (any, () -> ()) -> ())
	local failsafe = Promise.delay(60):andThen(function()
		self:Desist(guid)
	end)

	self.Persistents[guid] = function(update: any)
		handler(update, function()
			failsafe:cancel()
			self:Desist(guid)
		end)
	end
end

function EffectController.Desist(self: EffectController, guid: string)
	self.Persistents[guid] = nil
end

return EffectController
