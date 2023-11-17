local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Observers = require(ReplicatedStorage.Packages.Observers)
local SessionRewardsSession = require(ServerScriptService.Server.Classes.SessionRewardsSession)

local SessionRewardsService = {
	Priority = 0,
}

type SessionRewardsService = typeof(SessionRewardsService)

function SessionRewardsService.PrepareBlocking(self: SessionRewardsService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "SessionRewards")
	self.StatusRemote = self.Comm:CreateProperty("Status", {})

	Observers.observePlayer(function(player)
		local session = SessionRewardsSession.new(player)

		session:Observe(function(status)
			self.StatusRemote:SetFor(player, status)
		end)

		return function()
			session:Destroy()
		end
	end)
end

return SessionRewardsService
