local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local BattleController = {
	Priority = 0,
}

type BattleController = typeof(BattleController)

function BattleController.PrepareBlocking(self: BattleController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "BattleService")

	self.Comm:GetProperty("Status"):Observe(function(...)
		self:OnStatusUpdated(...)
	end)
end

function BattleController.Start(self: BattleController) end

function BattleController.OnStatusUpdated(self: BattleController, status: any?)
	if status then
		print("BATTLE STARTED")
	else
		print("BATTLE ENDED")
	end
end

return BattleController
