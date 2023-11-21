local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local GoonPreview = require(ReplicatedStorage.Shared.React.Goons.GoonPreview)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	CardId: string,
})
	local cardDef = CardDefs[props.CardId]
	local name

	if cardDef.Type == "Goon" then
		local goonDef = GoonDefs[cardDef.GoonId]
		name = goonDef.Name
	else
		error(`Card type {cardDef.Type} not yet implemented`)
	end

	return React.createElement(Panel, {
		ImageColor3 = ColorDefs.PaleGreen,
	}, {
		Name = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.2),
			Text = TextStroke(name),
		}),

		Preview = React.createElement(Container, {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.2),
		}, {
			Goon = React.createElement(GoonPreview, {
				GoonId = cardDef.GoonId,
			}),
		}),
	})
end
