local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local CurrencyHelper = require(ReplicatedStorage.Shared.Util.CurrencyHelper)
local FormatChance = require(ReplicatedStorage.Shared.Util.FormatChance)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetGachaDefs = require(ReplicatedStorage.Shared.Defs.PetGachaDefs)
local PetPreview = require(ReplicatedStorage.Shared.React.PetGacha.PetPreview)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function petPanel(props: {
	PetId: string,
	Chance: number,
})
	local petDef = PetDefs[props.PetId]

	return React.createElement(Panel, {
		ImageColor3 = ColorDefs.PaleGreen,
	}, {
		Name = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.2),
			Text = TextStroke(petDef.Name),
			ZIndex = 4,
		}),

		Preview = React.createElement(PetPreview, {
			PetId = props.PetId,
		}),

		Chance = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.2),
			Text = TextStroke(FormatChance(props.Chance)),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			ZIndex = 4,
		}),
	})
end

local function buyButton(props: {
	CanAfford: boolean,
	Count: number,
	Price: number,
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
			Text = TextStroke(`Hatch {props.Count}`),
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
	local gacha = PetGachaDefs[props.GachaId]

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke(gacha.Name, 2),
		[React.Event.Activated] = props.Close,
		Ratio = 1.05,
	}, {
		Buttons = React.createElement(Container, {
			Size = UDim2.new(1, 0, 0.15, -8),
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
				Sift.Array.map({ 1, 5, 25, 50 }, function(count, index)
					return React.createElement(buyButton, {
						LayoutOrder = index,
						CanAfford = CurrencyHelper.CheckPrice(props.Wallet, gacha.Price, count),
						Count = count,
						Price = gacha.Price.Secondary * count,
						Activate = function()
							props.Buy(count)
						end,
						SelectionOrder = index,
					})
				end)
			),
		}),

		PetsContainer = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.85),
		}, {
			Layout = React.createElement(GridLayout, {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				CellSize = UDim2.fromScale(0.333, 1),
			}, {
				Aspect = React.createElement(Aspect, {
					AspectRatio = 1,
				}),
			}),

			Pets = React.createElement(
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
							LayoutOrder = index,
						}, {
							Panel = React.createElement(petPanel, {
								PetId = entry.Result,
								Chance = entry.Chance,
							}),
						}),
							entry.Result
					end
				)
			),
		}),
	})
end
