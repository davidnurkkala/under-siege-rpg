local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function currencyPanel(props: {
	Id: string,
	Amount: number,
	LayoutOrder: number,
})
	local def = CurrencyDefs[props.Id]

	return React.createElement(Container, {
		[React.Tag] = `GuiPanel{props.Id}`,

		Size = UDim2.fromScale(0.1, 0.033),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		LayoutOrder = props.LayoutOrder,
	}, {
		React.createElement(Panel, {
			ImageColor3 = def.Colors.Primary,
			BorderColor3 = def.Colors.Secondary,
		}, {
			Label = React.createElement(Label, {
				Size = UDim2.fromScale(0.75, 1),
				Position = UDim2.fromScale(0.75, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				Text = TextStroke(`{FormatBigNumber(props.Amount)}`, 2),
			}),

			Icon = React.createElement(Image, {
				Size = UDim2.fromScale(0.25, 0.25),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Image = def.Image,
			}),
		}),
	})
end

return function()
	local menu = React.useContext(MenuContext)
	local currency, setCurrency = React.useState({})

	React.useEffect(function()
		local connection = CurrencyController.CurrencyRemote:Observe(setCurrency)

		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement(Container, nil, {
		Layout = React.createElement(ListLayout, {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = if menu.Is(nil) then Enum.VerticalAlignment.Top else Enum.VerticalAlignment.Bottom,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.025, 0),
		}),

		Currencies = React.createElement(
			React.Fragment,
			nil,
			Sift.Dictionary.map({ "Primary", "Secondary", "Premium" }, function(id, index)
				return React.createElement(currencyPanel, {
					Id = id,
					Amount = currency[id] or 0,
					LayoutOrder = index,
				}), `{id}Panel`
			end)
		),
	})
end
