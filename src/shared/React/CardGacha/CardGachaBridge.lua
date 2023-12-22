local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardGacha = require(ReplicatedStorage.Shared.React.CardGacha.CardGacha)
local CardGachaResult = require(ReplicatedStorage.Shared.React.CardGacha.CardGachaResult)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local DeckController = require(ReplicatedStorage.Shared.Controllers.DeckController)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local ProductController = require(ReplicatedStorage.Shared.Controllers.ProductController)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zoner = require(ReplicatedStorage.Shared.Classes.Zoner)

return function()
	local menu = React.useContext(MenuContext)
	local currency, setCurrency = React.useState(nil)
	local gachaId, setGachaId = React.useState(nil)
	local state, setState = React.useState("Shop")
	local resultCardId, setResultCardId = React.useState(nil)
	local resultCardCount, setResultCardCount = React.useState(nil)
	local buys = React.useRef(0)

	local buy = React.useCallback(function()
		buys.current -= 1

		setState("Waiting")
		DeckController:DrawCardFromGacha(gachaId):andThen(function(success, cardId, cardCount)
			if not success then
				setState("Shop")
				return
			end

			setResultCardId(cardId)
			setResultCardCount(cardCount)
			setState("Result")
		end)
	end, { gachaId, buys })

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(CurrencyController:ObserveCurrency(setCurrency))

		trove:Add(Zoner.new(Players.LocalPlayer, "CardGachaZone", function(entered, zone)
			if entered then
				setGachaId(zone:GetAttribute("GachaId"))
				menu.Set("CardGacha")
			else
				menu.Unset("CardGacha")
			end
		end))

		return function()
			trove:Clean()
		end
	end, {})

	local isDataReady = (gachaId ~= nil) and (currency ~= nil)

	return React.createElement(React.Fragment, nil, {
		Gacha = isDataReady and React.createElement(CardGacha, {
			Visible = menu.Is("CardGacha") and (state == "Shop"),
			GachaId = gachaId,
			Wallet = currency,
			Buy = function(count)
				if count > 1 then
					setState(nil)
					ProductController.GetOwnsProduct("MultiRoll")
						:andThen(function(owned)
							if owned then
								buys.current = count
								buy()
							else
								setState("Sell")
							end
						end)
						:catch(function()
							setState("Shop")
						end)
				else
					buys.current = count
					buy()
				end
			end,
			Close = function()
				menu.Unset("CardGacha")
			end,
		}),

		Sell = React.createElement(PromptWindow, {
			Visible = state == "Sell",
			HeaderText = TextStroke("Buy Multi-buy"),
			Text = TextStroke("Multi-buy can be bought by itself, but it's free for Premium users!"),
			TextSize = 0.5,
			[React.Event.Activated] = function()
				GuiService.SelectedObject = nil
				setState("Shop")
			end,
			Options = {
				{
					Text = TextStroke("Buy\nPass"),
					Select = function()
						setState(nil)
						ProductController.PurchaseProduct("MultiRoll"):finally(function()
							setState("Shop")
						end)
					end,
					Props = {
						ImageColor3 = ColorDefs.PaleGreen,
					},
				},
				{
					Text = TextStroke("Buy\nPremium"),
					Select = function()
						setState(nil)
						ProductController.PurchasePremium():finally(function()
							setState("Shop")
						end)
					end,
					Props = {
						ImageColor3 = ColorDefs.PaleYellow,
					},
				},
				{
					Text = TextStroke("Cancel"),
					Select = function()
						setState("Shop")
					end,
				},
			},
		}),

		Result = (state == "Result") and React.createElement(CardGachaResult, {
			CardId = resultCardId,
			CardCount = resultCardCount,
			Close = function()
				if buys.current > 0 then
					buy()
				else
					setState("Shop")
				end
			end,
		}),
	})
end
