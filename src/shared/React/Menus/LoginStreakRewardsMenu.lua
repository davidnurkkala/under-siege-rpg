local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
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
		HeaderSize = 0.2,
		Ratio = 3,
	}, {
		Message = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.4),
			Text = TextStroke(`Your current login streak is {props.Streak} day{if props.Streak > 1 then "s" else ""} long!`),
		}),
		Grid = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.6),
			Position = UDim2.fromScale(0, 0.4),
		}, {
			Layout = React.createElement(GridLayout, {
				CellSize = UDim2.fromScale(1 / 7, 1),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}, {
				Aspect = React.createElement(Aspect, {
					AspectRatio = 1,
				}),
			}),

			Buttons = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map(LoginStreakRewardDefs, function(reward, index)
					local isBoost = reward.Type == "Boost"
					local isAvailable = Sift.Array.some(props.AvailableRewardIndices, function(rewardIndex)
						local normalized = ((rewardIndex - 1) % #LoginStreakRewardDefs) + 1
						return normalized == index
					end)

					return React.createElement(LayoutContainer, {
						Padding = 8,
						LayoutOrder = index,
					}, {
						Button = React.createElement(Button, {
							Size = UDim2.fromScale(1, 1),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
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

							Image = React.createElement(Container, {
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Size = if isBoost then UDim2.fromScale(0.6, 0.6) else UDim2.fromScale(1, 1),
							}, {
								Image = React.createElement(Image, {
									Image = RewardDisplayHelper.GetRewardImage(reward),
									AnchorPoint = Vector2.new(0, 1),
									Position = UDim2.fromScale(0, 1),
									Size = if isBoost then UDim2.fromScale(0.75, 0.75) else UDim2.fromScale(1, 1),
								}),

								Arrow = isBoost and React.createElement(Image, {
									Image = "rbxassetid://15548681925",
									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.fromScale(1, 0),
									Size = UDim2.fromScale(0.75, 0.75),
									ImageColor3 = ColorDefs.Yellow,
									ZIndex = 2,
								}),
							}),
						}),
					})
				end)
			),
		}),
	})
end
