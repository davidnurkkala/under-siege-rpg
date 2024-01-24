local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoostController = require(ReplicatedStorage.Shared.Controllers.BoostController)
local BoostHelper = require(ReplicatedStorage.Shared.Util.BoostHelper)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local FormatTime = require(ReplicatedStorage.Shared.Util.FormatTime)
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
	Inverted: boolean,
})
	local def = CurrencyDefs[props.Id]

	local boostInfo, setBoostInfo = React.useState(nil)

	local predicate = React.useCallback(function(boost)
		return (boost.Type == "Currency") and (boost.CurrencyType == props.Id)
	end, { props.Id })

	React.useEffect(function()
		return BoostController:ObserveBoosts(function(boosts)
			if boosts == nil then return end

			local multiplier = BoostHelper.GetMultiplier(boosts, predicate)
			local t = BoostHelper.GetTime(boosts, predicate)

			if multiplier == 1 then
				setBoostInfo(nil)
				return
			end
			if t == 0 then
				setBoostInfo(nil)
				return
			end

			setBoostInfo({ Multiplier = multiplier, Time = t })
		end)
	end, { props.Id })

	return React.createElement(Container, {
		[React.Tag] = `GuiPanel{props.Id}`,

		Size = UDim2.fromScale(0.2, 0.075),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = props.LayoutOrder,
	}, {
		Constraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(100, 40),
		}),

		Layout = React.createElement(ListLayout, {
			VerticalAlignment = if props.Inverted then Enum.VerticalAlignment.Bottom else Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 6),
		}),

		Boost = (boostInfo ~= nil) and React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.5),
			LayoutOrder = if props.Inverted then 1 else 2,
			Text = TextStroke(`{boostInfo.Multiplier // 0.1 / 10}x {FormatTime(boostInfo.Time)}`),
		}),

		Panel = React.createElement(Panel, {
			LayoutOrder = if props.Inverted then 2 else 1,
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
			Sift.Dictionary.map({ "Coins", "Gems" }, function(id, index)
				return React.createElement(currencyPanel, {
					Id = id,
					Amount = currency[id] or 0,
					LayoutOrder = index,
					Inverted = not menu.Is(nil),
				}),
					`{id}Panel`
			end)
		),
	})
end
