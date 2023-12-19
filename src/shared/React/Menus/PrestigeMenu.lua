local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local FormatChance = require(ReplicatedStorage.Shared.Util.FormatChance)
local FormatCommaNumber = require(ReplicatedStorage.Shared.Util.FormatCommaNumber)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local PrestigeHelper = require(ReplicatedStorage.Shared.Util.PrestigeHelper)
local React = require(ReplicatedStorage.Packages.React)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Visible: boolean,
	Close: () -> (),
	Prestige: (string) -> (),
	CanAfford: boolean,
	Cost: number,
	PrestigePoints: {
		Primary: number,
		Secondary: number,
	},
})
	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke("Rebirth"),
		[React.Event.Activated] = props.Close,
	}, {
		Layout = React.createElement(ListLayout, {
			Padding = UDim.new(0.05, 0),
		}),

		Description = React.createElement(Label, {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0.3),
			Text = TextStroke("Reset your progress to gain a permanent buff.\nYou will keep your pets, soldiers, abilities, and cosmetics."),
		}),

		Cost = React.createElement(LayoutContainer, {
			Padding = 4,
			Size = UDim2.fromScale(1, 0.15),
			LayoutOrder = 2,
		}, {
			Layout = React.createElement(ListLayout, {
				FillDirection = Enum.FillDirection.Horizontal,
			}),

			Label = React.createElement(Label, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.6, 1),
				Text = TextStroke(`{FormatCommaNumber(props.Cost)}`),
				TextColor3 = CurrencyDefs.Primary.Colors.Primary,
				TextXAlignment = Enum.TextXAlignment.Right,
			}),

			Icon = React.createElement(Image, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = CurrencyDefs.Primary.Image,
			}),
		}),

		Buttons = React.createElement(LayoutContainer, {
			Padding = 12,
			Size = UDim2.fromScale(1, 0.45),
			LayoutOrder = 3,
		}, {
			Layout = React.createElement(ListLayout, {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.1, 0),
			}),

			Primary = React.createElement(Button, {
				Active = props.CanAfford,
				LayoutOrder = 1,
				Size = UDim2.fromScale(2, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ImageColor3 = if props.CanAfford then CurrencyDefs.Primary.Colors.Secondary else nil,
				[React.Event.Activated] = function()
					props.Prestige("Primary")
				end,
			}, {
				Image = React.createElement(Image, {
					Image = CurrencyDefs.Primary.Image,
				}),
				Text = React.createElement(Label, {
					ZIndex = 4,
					Size = UDim2.fromScale(1, 0.4),
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 1),
					Text = TextStroke(
						`{FormatChance(PrestigeHelper.GetBoost(props.PrestigePoints.Primary))} → {FormatChance(PrestigeHelper.GetBoost(props.PrestigePoints.Primary + 1))}`,
						2
					),
				}),
			}),

			Secondary = React.createElement(Button, {
				Active = props.CanAfford,
				LayoutOrder = 2,
				Size = UDim2.fromScale(2, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ImageColor3 = if props.CanAfford then CurrencyDefs.Secondary.Colors.Secondary else nil,
				[React.Event.Activated] = function()
					props.Prestige("Secondary")
				end,
			}, {
				Image = React.createElement(Image, {
					Image = CurrencyDefs.Secondary.Image,
				}),
				Text = React.createElement(Label, {
					ZIndex = 4,
					Size = UDim2.fromScale(1, 0.4),
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 1),
					Text = TextStroke(
						`{FormatChance(PrestigeHelper.GetBoost(props.PrestigePoints.Secondary))} → {FormatChance(PrestigeHelper.GetBoost(props.PrestigePoints.Secondary + 1))}`,
						2
					),
				}),
			}),
		}),
	})
end
