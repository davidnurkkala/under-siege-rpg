local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local HeightText = require(ReplicatedStorage.Shared.React.Common.HeightText)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local Promise = require(ReplicatedStorage.Packages.Promise)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local React = require(ReplicatedStorage.Packages.React)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local function entry(props: {
	LayoutOrder: number,
	Reward: any,
})
	local slide, slideMotor = UseMotor(-1)

	React.useEffect(function()
		local promise = Promise.delay(2 + (props.LayoutOrder * 0.25)):andThen(function()
			slideMotor:setGoal(Flipper.Spring.new(0, { dampingRatio = 0.5 }))
		end)

		return function()
			promise:cancel()
		end
	end, {})

	return React.createElement(LayoutContainer, {
		Padding = 6,
		Size = UDim2.fromScale(1, 0.15),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		LayoutOrder = props.LayoutOrder,
	}, {
		Contents = React.createElement(Container, {
			Position = slide:map(function(value)
				return UDim2.fromScale(2 * value, 0)
			end),
		}, {
			Layout = React.createElement(ListLayout, {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
			}),

			Image = React.createElement(Panel, {
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 1,
				ImageColor3 = RewardDisplayHelper.GetRewardColor(props.Reward),
			}, {
				Content = RewardDisplayHelper.CreateRewardElement(props.Reward),
			}),

			Text = React.createElement(HeightText, {
				Size = UDim2.fromScale(0, 0.8),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 2,
				Text = TextStroke(RewardDisplayHelper.GetRewardText(props.Reward)),
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}),
	})
end

return function(props: {
	Rewards: { any },
	Close: () -> (),
})
	local height, heightMotor = UseMotor(-1)

	React.useEffect(function()
		heightMotor:setGoal(Flipper.Instant.new(-1))
		heightMotor:step()

		local promise = Promise.delay(1.5):andThen(function()
			heightMotor:setGoal(Flipper.Spring.new(0))
		end)

		return function()
			promise:cancel()
		end
	end, {})

	return React.createElement(Container, {
		Position = height:map(function(value)
			return UDim2.fromScale(0, value)
		end),
	}, {
		Layout = React.createElement(ListLayout, {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 12),
		}),

		Main = React.createElement(Panel, {
			ImageColor3 = ColorDefs.DarkGreen,
			Size = UDim2.fromScale(0.35, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 8),
			}),

			Header = React.createElement(Label, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0.15),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Text = TextStroke("Victory!"),
			}),

			Content = React.createElement(Container, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Layout = React.createElement(ListLayout),

				Rewards = React.createElement(
					React.Fragment,
					nil,
					Sift.Array.map(props.Rewards, function(reward, index)
						return React.createElement(entry, {
							LayoutOrder = index,
							Reward = reward,
						})
					end)
				),
			}),

			Spacer = React.createElement(Container, {
				Size = UDim2.new(1, 0, 0, 8),
				LayoutOrder = 3,
			}),
		}),

		ConfirmButton = React.createElement(Button, {
			Size = UDim2.fromScale(0.15, 0.15 / 3),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			LayoutOrder = 4,
			ImageColor3 = ColorDefs.PalePurple,

			[React.Event.Activated] = function()
				PromiseMotor(heightMotor, Flipper.Spring.new(-1), function(value)
					return value < -0.95
				end):finallyCall(props.Close)
			end,
		}, {
			Label = React.createElement(Label, {
				Text = TextStroke("Okay"),
			}),
		}),
	})
end
