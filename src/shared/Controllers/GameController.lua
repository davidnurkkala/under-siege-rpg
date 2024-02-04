local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local GameController = {
	Priority = 0,
}

type GameController = typeof(GameController)

function GameController.PrepareBlocking(self: GameController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "GameService")
	self.Play = self.Comm:GetFunction("Play")
end

return GameController
