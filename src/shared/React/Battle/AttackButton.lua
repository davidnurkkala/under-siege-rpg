local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local PrimaryButton = require(ReplicatedStorage.Shared.React.Common.PrimaryButton)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	LayoutOrder: number,
})
	local platform = React.useContext(PlatformContext)

	return React.createElement(PrimaryButton, {
		LayoutOrder = props.LayoutOrder,
		Selectable = false,
	}, {
		GamepadHint = React.createElement(RoundButtonWithImage, {
			Visible = platform == "Console",
			Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonR2),
			Text = "Charge Crit",
			Selectable = false,
			Position = UDim2.new(0.5, 0, 1, 4),
			AnchorPoint = Vector2.new(0.5, 0),
			height = UDim.new(0.4, 0),
		}),

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
