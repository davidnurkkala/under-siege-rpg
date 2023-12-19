local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatChance = require(ReplicatedStorage.Shared.Util.FormatChance)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local PrestigeController = require(ReplicatedStorage.Shared.Controllers.PrestigeController)
local PrestigeHelper = require(ReplicatedStorage.Shared.Util.PrestigeHelper)
local PrestigeMenu = require(ReplicatedStorage.Shared.React.Menus.PrestigeMenu)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local TextColor = require(ReplicatedStorage.Shared.React.Util.TextColor)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)

return function()
	local menu = React.useContext(MenuContext)

	local points, setPoints = React.useState(nil)
	local currency, setCurrency = React.useState(nil)

	local confirm, setConfirm = React.useState(false)
	local prestigeType = React.useRef(nil)

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(PrestigeController:ObservePoints(setPoints))
		trove:Add(CurrencyController:ObserveCurrency(setCurrency))

		return function()
			trove:Clean()
		end
	end, {})

	local isDataReady = (points ~= nil) and (currency ~= nil)
	local cost = isDataReady and PrestigeHelper.GetCost(currency.Prestige)

	return React.createElement(React.Fragment, nil, {
		Menu = isDataReady and React.createElement(PrestigeMenu, {
			Visible = menu.Is("Prestige") and not confirm,
			Cost = cost,
			CanAfford = currency.Primary >= cost,
			PrestigePoints = points,
			Close = function()
				menu.Unset("Prestige")
			end,
			Prestige = function(t)
				prestigeType.current = t
				setConfirm(true)
			end,
		}),

		Confirm = (prestigeType.current ~= nil) and React.createElement(PromptWindow, {
			HeaderText = TextStroke("Confirm Rebirth"),
			Ratio = 1,
			HeaderSize = 0.1,
			TextSize = 0.8,
			Visible = confirm,
			[React.Event.Activated] = function()
				setConfirm(false)
			end,
			Text = TextStroke(
				`Are you sure you want to rebirth, resetting most of your progress and permanently boosting your {TextColor(
					CurrencyDefs[prestigeType.current].Name,
					CurrencyDefs[prestigeType.current].Colors.Secondary
				)} gain to {FormatChance(
					PrestigeHelper.GetBoost(points[prestigeType.current] + 1)
				)}?`
			),
			Options = {
				{
					Text = TextStroke("Yes"),
					Select = function()
						PrestigeController.PrestigeRemote(prestigeType.current)
						menu.Unset("Prestige")
						setConfirm(false)
					end,
				},
				{
					Text = TextStroke("No"),
					Select = function()
						setConfirm(false)
					end,
				},
			},
		}),
	})
end
