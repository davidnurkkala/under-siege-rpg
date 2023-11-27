local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CardContents = require(ReplicatedStorage.Shared.React.Cards.CardContents)
local CardGachaDefs = require(ReplicatedStorage.Shared.Defs.CardGachaDefs)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local CurrencyHelper = require(ReplicatedStorage.Shared.Util.CurrencyHelper)
local FormatChance = require(ReplicatedStorage.Shared.Util.FormatChance)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local CardWidth = 2.5 / 3.5

return function(props: {
	GachaId: string,
	Visible: boolean,
	Close: () -> (),
	Buy: () -> (),
	Wallet: CurrencyHelper.Wallet,
})
	local gacha = CardGachaDefs[props.GachaId]
	local canAfford = CurrencyHelper.CheckPrice(props.Wallet, gacha.Price)

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke(gacha.Name, 2),
		[React.Event.Activated] = props.Close,
	}, {
		BuyButton = React.createElement(Button, {
			Size = UDim2.new(0.4, 0, 0.2, -8),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			ImageColor3 = if canAfford then ColorDefs.Yellow else ColorDefs.PaleBlue,
			BorderColor3 = if canAfford then nil else ColorDefs.PaleBlue,
			Active = canAfford,
			[React.Event.Activated] = props.Buy,
		}, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
			}),

			Text = React.createElement(Label, {
				Text = TextStroke(
					`<b>{if canAfford then "Buy!" else "Need"}</b>   <font color="#{CurrencyDefs.Secondary.Colors.Primary:ToHex()}">{gacha.Price.Secondary}</font>`
				),
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				LayoutOrder = 1,
				TextColor3 = if canAfford then nil else ColorDefs.PaleRed,
			}),

			Icon = React.createElement(Image, {
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = CurrencyDefs.Secondary.Image,
				LayoutOrder = 2,
			}),
		}),

		CardsContainer = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.8),
		}, {
			Layout = React.createElement(ListLayout, {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
			}),

			Cards = React.createElement(
				React.Fragment,
				nil,
				Sift.Dictionary.map(
					Sift.Array.sort(gacha.WeightTable:GetEntries(), function(a, b)
						if a.Chance == b.Chance then
							return a.Result < b.Result
						else
							return a.Chance > b.Chance
						end
					end),
					function(entry, index)
						return React.createElement(LayoutContainer, {
							Padding = 4,
							Size = UDim2.fromScale(0.25, 1),
							LayoutOrder = index,
						}, {
							Card = React.createElement(Container, {
								Size = UDim2.fromScale(CardWidth * 0.8, 0.8),
								SizeConstraint = Enum.SizeConstraint.RelativeYY,
							}, {
								Contents = React.createElement(CardContents, {
									CardId = entry.Result,
									StatsDisabled = true,
								}),
							}),

							Chance = React.createElement(Label, {
								ZIndex = 8,
								Size = UDim2.fromScale(1, 0.2),
								Text = TextStroke(FormatChance(entry.Chance)),
								AnchorPoint = Vector2.new(0, 1),
								Position = UDim2.fromScale(0, 1),
							}),
						}),
							entry.Result
					end
				)
			),
		}),
	})
end
