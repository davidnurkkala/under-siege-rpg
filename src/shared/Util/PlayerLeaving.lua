local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

return function(player)
	return Promise.fromEvent(Players.PlayerRemoving, function(leavingPlayer)
		return leavingPlayer == player
	end)
end
