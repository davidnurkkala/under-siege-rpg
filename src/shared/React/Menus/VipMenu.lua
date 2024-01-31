local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local React = require(ReplicatedStorage.Packages.React)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextColor = require(ReplicatedStorage.Shared.React.Util.TextColor)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Visible: boolean,
	Owned: boolean,
	Close: () -> (),
	Buy: () -> (),
})
	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		[React.Event.Activated] = props.Close,
		HeaderText = TextStroke(if props.Owned then "VIP Benefits" else "Buy VIP!"),
	}, {
		Description = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.7),
			Text = TextStroke(
				`• Special {TextColor("chat tag", ColorDefs.PaleGreen)}\n• 10% more {TextColor("coins", ColorDefs.PaleYellow)}\n• 25% higher {TextColor(
					"luck",
					ColorDefs.Green
				)} on loot rolls`
			),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		Button = (not props.Owned) and React.createElement(Button, {
			Size = UDim2.fromScale(0.3, 0.25),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			ImageColor3 = ColorDefs.Yellow,
			[React.Event.Activated] = props.Buy,
			SelectionOrder = -1,
		}, {
			Text = React.createElement(Label, {
				Text = "BUY!",
			}),
		}),

		Thanks = props.Owned and React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.25),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			Text = TextStroke(`You are a VIP. Thank you very much!`),
		}),
	})
end
