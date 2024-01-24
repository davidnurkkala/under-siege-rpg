local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local LoginStreakRewardDefs = require(ReplicatedStorage.Shared.Defs.LoginStreakRewardDefs)
local React = require(ReplicatedStorage.Packages.React)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Visible: boolean,
	Close: () -> (),
	Claim: (number) -> (),
	AvailableRewardIndices: { number },
	Streak: number,
})
	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke("Login Streak"),
		[React.Event.Activated] = props.Close,
		RatioDisabled = true,
		Size = UDim2.fromScale(0.8, 0.3),
		HeaderSize = 0.2,
	}, {
		Message = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.25),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = TextStroke(`Your current login streak is {props.Streak} day{if props.Streak > 1 then "s" else ""} long.`),
		}),
		Grid = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.75),
			Position = UDim2.fromScale(0, 0.25),
		}, {
			Layout = React.createElement(GridLayout, {
				CellSize = UDim2.fromScale(1 / 7, 1),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Buttons = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map(LoginStreakRewardDefs, function(reward, index)
					local isAvailable = Sift.Array.some(props.AvailableRewardIndices, function(rewardIndex)
						local normalized = ((rewardIndex - 1) % #LoginStreakRewardDefs) + 1
						return normalized == index
					end)

					return React.createElement(LayoutContainer, {
						Padding = 8,
						LayoutOrder = index,
					}, {
						Layout = React.createElement(ListLayout, {
							VerticalAlignment = Enum.VerticalAlignment.Center,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 8),
						}),

						Label = React.createElement(Label, {
							Size = UDim2.fromScale(0.75, 0.5),
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
							LayoutOrder = 1,
							Text = TextStroke(`Day {index}`),
						}),

						Button = React.createElement(Button, {
							LayoutOrder = 2,
							Size = UDim2.fromScale(1, 1),
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
							Active = isAvailable,
							ImageColor3 = if isAvailable then ColorDefs.LightGreen else ColorDefs.PaleBlue,
							[React.Event.Activated] = function()
								props.Claim(index)
							end,
							[React.Tag] = `LoginStreakRewardButton{index}`,
							SelectionOrder = if isAvailable then -1 else 1,
						}, {
							Text = React.createElement(Label, {
								Text = TextStroke(RewardDisplayHelper.GetRewardText(reward)),
								Size = UDim2.fromScale(1, 0.5),
								ZIndex = 4,
							}),

							Image = React.createElement(Image, {
								Image = RewardDisplayHelper.GetRewardImage(reward),
							}),
						}),
					})
				end)
			),
		}),
	})
end
