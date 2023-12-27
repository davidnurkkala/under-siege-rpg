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
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local CardWidth = 2.5 / 3.5

local function buyButton(props: {
	CanAfford: boolean,
	Count: number,
	Price: number,
	Verb: string,
	LayoutOrder: number,
	Activate: () -> (),
	SelectionOrder: number?,
	OnSelectionGained: any,
})
	return React.createElement(Button, {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(2, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		ImageColor3 = if props.CanAfford then ColorDefs.Yellow else ColorDefs.PaleBlue,
		BorderColor3 = if props.CanAfford then nil else ColorDefs.PaleBlue,
		Active = props.CanAfford,
		SelectionOrder = props.SelectionOrder,
		[React.Event.Activated] = props.Activate,
		[React.Event.SelectionGained] = props.OnSelectionGained,
	}, {
		CountText = React.createElement(Label, {
			Text = TextStroke(`{props.Verb} {props.Count}`),
			Size = UDim2.fromScale(1, 0.5),
		}),

		PriceText = React.createElement(Label, {
			Text = TextStroke(`<font color="#{CurrencyDefs.Secondary.Colors.Primary:ToHex()}">{props.Price}</font>`),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromScale(0.6, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			LayoutOrder = 1,
			TextColor3 = if props.CanAfford then nil else ColorDefs.PaleRed,
		}),

		Icon = React.createElement(Image, {
			Size = UDim2.fromScale(0.4, 0.5),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
			Image = CurrencyDefs.Secondary.Image,
			LayoutOrder = 2,
		}),
	})
end

return function(props: {
	GachaId: string,
	Visible: boolean,
	Close: () -> (),
	Buy: (number) -> (),
	Wallet: CurrencyHelper.Wallet,
})
	local gacha = CardGachaDefs[props.GachaId]

	React.useEffect(function()
		if not props.Visible then return end
	end, { props.Visible })

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke(gacha.Name, 2),
		[React.Event.Activated] = props.Close,
		Ratio = 1.4,
	}, {
		Buttons = React.createElement(Container, {
			Size = UDim2.new(1, 0, 0.2, -8),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
		}, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 12),
			}),

			Buttons = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map({ 1, 10, 50, 100 }, function(count, index)
					return React.createElement(buyButton, {
						LayoutOrder = index,
						CanAfford = CurrencyHelper.CheckPrice(props.Wallet, gacha.Price, count),
						Count = count,
						Price = gacha.Price.Secondary * count,
						Verb = gacha.Verb,
						Activate = function()
							props.Buy(count)
						end,
						SelectionOrder = index,
					})
				end)
			),
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
							Size = UDim2.fromScale(0.333, 1),
							LayoutOrder = index,
						}, {
							Card = React.createElement(Panel, {
								AnchorPoint = Vector2.new(0.5, 0),
								Position = UDim2.fromScale(0.5, 0),
								Size = UDim2.fromScale(CardWidth * 0.8, 0.8),
								SizeConstraint = Enum.SizeConstraint.RelativeYY,
								ImageColor3 = ColorDefs.PaleGreen,
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
