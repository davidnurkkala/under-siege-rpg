local ServerScriptService = game:GetService("ServerScriptService")

local DeckService = require(ServerScriptService.Server.Services.DeckService)

return function(_context, player, cardId)
	DeckService:AddCard(player, cardId)

	return "Success"
end
