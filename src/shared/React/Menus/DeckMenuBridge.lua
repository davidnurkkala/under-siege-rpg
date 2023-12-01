local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeckController = require(ReplicatedStorage.Shared.Controllers.DeckController)
local DeckMenu = require(ReplicatedStorage.Shared.React.Menus.DeckMenu)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local menu = React.useContext(MenuContext)
	local deck, setDeck = React.useState(nil)

	React.useEffect(function()
		return DeckController:ObserveDeck(setDeck)
	end, {})

	local isDataReady = deck ~= nil

	return isDataReady and React.createElement(DeckMenu, {
		Visible = menu.Is("Deck"),
		Deck = deck,
		Close = function()
			menu.Unset("Deck")
		end,
	})
end
