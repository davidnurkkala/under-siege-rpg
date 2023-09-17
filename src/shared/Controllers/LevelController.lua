local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local LevelController = {
	Priority = 0,
}

type LevelController = typeof(LevelController)

function LevelController.PrepareBlocking(self: LevelController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "LevelService")
	self.Comm:GetProperty("Level"):Observe(function(level)
		print("My level is", level)
	end)
	self.Comm:GetProperty("Experience"):Observe(function(experience)
		print("My experience is", experience)
	end)
	self.Comm:GetProperty("PrestigeCount"):Observe(function(prestigeCount)
		print("My prestige count is", prestigeCount)
	end)
end

function LevelController.Start(self: LevelController) end

return LevelController
