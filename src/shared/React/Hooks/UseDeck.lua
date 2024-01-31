local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeckController = require(ReplicatedStorage.Shared.Controllers.DeckController)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local deck, setDeck = React.useState({})

	React.useEffect(function()
		return DeckController:ObserveDeck(function(deckIn)
			setDeck(deckIn)
		end)
	end, {})

	return deck
end
