local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Server.Services.DataService)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(_context, player, cardId)
	DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Deck", function(deck)
			return Sift.Dictionary.update(deck, "Owned", function(owned)
				return Sift.Dictionary.set(owned, cardId, 1)
			end)
		end)
	end)

	return "Success"
end
