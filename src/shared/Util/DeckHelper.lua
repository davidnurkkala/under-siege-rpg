local DeckHelper = {}

function DeckHelper.OwnsCard(deck: any, cardId: string)
	if not deck.Owned then return false end

	return deck.Owned[cardId]
end

return DeckHelper
