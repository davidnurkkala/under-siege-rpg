local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Sift = require(ReplicatedStorage.Packages.Sift)

local WorldController = {
	Priority = 0,
}

type WorldController = typeof(WorldController)

function WorldController.PrepareBlocking(self: WorldController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "WorldService")
	self.WorldsRemote = self.Comm:GetProperty("Worlds")
	self.WorldCurrentRemote = self.Comm:GetProperty("WorldCurrent")
	self.WorldTeleportRequested = self.Comm:GetSignal("WorldTeleportRequested")

	local worldModelsById = Sift.Dictionary.map(workspace.Worlds:GetChildren(), function(model)
		return model, model.Name
	end)

	self.WorldCurrentRemote:Observe(function(worldCurrent)
		for id, model in worldModelsById do
			if id == worldCurrent then
				model.Parent = workspace.Worlds
			else
				model.Parent = nil
			end
		end
	end)
end

function WorldController.ObserveWorlds(self: WorldController, callback)
	local connection = self.WorldsRemote:Observe(callback)
	return function()
		connection:Disconnect()
	end
end

return WorldController
