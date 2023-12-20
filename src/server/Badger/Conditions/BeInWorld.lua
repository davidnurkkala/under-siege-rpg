local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local WorldService = require(ServerScriptService.Server.Services.WorldService)

return function(player, worldId)
	return Badger.create({
		getFilter = function()
			return {
				TeleportedToWorld = true,
			}
		end,
		getState = function()
			return {
				worldId = worldId,
			}
		end,
		isComplete = function()
			return WorldService:GetCurrentWorld(player):expect() == worldId
		end,
	})
end
