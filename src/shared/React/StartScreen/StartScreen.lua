local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Frame = require(ReplicatedStorage.Shared.React.Common.Frame)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Close: () -> (),
})
	local platform = React.useContext(PlatformContext)

	React.useEffect(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

		ContextActionService:BindActionAtPriority("CloseStartScreen", function(_, inputState)
			if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

			props.Close()
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonA)

		return function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
			ContextActionService:UnbindAction("CloseStartScreen")
		end
	end, { props.Close })

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
				Font = Enum.Font.Fantasy,
				LayoutOrder = 1,
			}),

			Subtitle = React.createElement(Label, {
				Size = UDim2.fromScale(1, 0.1 * 0.2),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Text = TextStroke(`Co-created by {table.concat(Sift.Array.shuffle({ "Davidii", "Chronomad" }), " and ")}`),
				Font = Enum.Font.Gotham,
				LayoutOrder = 2,
			}),

			Button = React.createElement(Frame, {
				Size = UDim2.fromScale(0.2, 0.2 * 0.3),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				BackgroundColor3 = ColorDefs.Black,
				LayoutOrder = 3,
			}, {
				Button = (platform ~= "Console") and React.createElement(Button, {
					ImageColor3 = ColorDefs.PalePurple,
					[React.Event.Activated] = props.Close,
				}, {
					Text = React.createElement(Label, {
						Text = TextStroke("Play"),
					}),
				}),

				GamepadHint = (platform == "Console") and React.createElement(RoundButtonWithImage, {
					Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonA),
					Text = "Play",
					Selectable = false,
					Position = UDim2.new(0.5, 0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					height = UDim.new(1, 0),
				}),
			}),
		}),
	})
end
