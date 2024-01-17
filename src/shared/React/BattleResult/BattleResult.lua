local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Rewards: { any },
	Close: () -> (),
})
	return React.createElement(Container, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 0.7),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
	}, {
		Header = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.15),
			Text = TextStroke("Victory!"),
		}),
		Subtitle = React.createElement(Label, {
			Position = UDim2.fromScale(0, 0.15),
			Size = UDim2.fromScale(1, 0.1),
			Text = TextStroke("<i>To the victor go the spoils...</i>"),
		}),
		Content = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.65),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.25),
		}, {
			Layout = React.createElement(ListLayout),

			Rewards = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map(props.Rewards, function(reward)
					return React.createElement(LayoutContainer, {
						Padding = 6,
						Size = UDim2.fromScale(1, 0.2),
					}, {
						Layout = React.createElement(ListLayout, {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 8),
						}),

						Image = React.createElement(Panel, {
							Size = UDim2.fromScale(1, 1),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							LayoutOrder = 1,
							ImageColor3 = RewardDisplayHelper.GetRewardColor(reward),
						}, {
							Content = RewardDisplayHelper.CreateRewardElement(reward),
						}),

						Text = React.createElement(Label, {
							Size = UDim2.fromScale(0.7, 1),
							LayoutOrder = 2,
							Text = TextStroke(RewardDisplayHelper.GetRewardText(reward)),
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
					})
				end)
			),
		}),
		ConfirmButton = React.createElement(Button, {
			ImageColor3 = ColorDefs.PalePurple,
			Size = UDim2.fromScale(0.3, 0.1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			[React.Event.Activated] = props.Close,
		}, {
			Label = React.createElement(Label, {
				Text = TextStroke("Okay"),
			}),
		}),
	})
end
