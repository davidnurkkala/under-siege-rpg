local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local PrimaryButton = require(ReplicatedStorage.Shared.React.Common.PrimaryButton)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	LayoutOrder: number,
})
	return React.createElement(PrimaryButton, {
		LayoutOrder = props.LayoutOrder,
	}, {
		Icon = React.createElement(Image, {
			Image = CurrencyDefs.Primary.Image,
		}),
		Text = React.createElement(Label, {
			ZIndex = 4,
			Size = UDim2.fromScale(1, 0.4),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			Text = TextStroke("CRIT!"),
		}),
	})
end
