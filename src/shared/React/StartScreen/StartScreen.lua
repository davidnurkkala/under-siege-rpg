local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Close: () -> (),
})
	React.useEffect(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

		return function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		end
	end, {})

	return React.createElement(Container, {
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 1024,
	}, {
		Background = React.createElement(Image, {
			Image = "rbxassetid://15169414872",
			ImageColor3 = ColorDefs.Gray25,
			ZIndex = -16,
		}),

		Stuff = React.createElement(Container, nil, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 24),
			}),

			Title = React.createElement(Label, {
				Size = UDim2.fromScale(1, 0.1),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Text = TextStroke("Under Siege RPG"),
				LayoutOrder = 1,
			}),

			Button = React.createElement(Button, {
				Size = UDim2.fromScale(0.2, 0.2 * 0.2),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				LayoutOrder = 2,
				ImageColor3 = ColorDefs.PalePurple,
				[React.Event.Activated] = props.Close,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke("Play"),
				}),
			}),
		}),
	})
end
