local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardGacha = require(ReplicatedStorage.Shared.React.CardGacha.CardGacha)
local CardGachaResult = require(ReplicatedStorage.Shared.React.CardGacha.CardGachaResult)
local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local DeckController = require(ReplicatedStorage.Shared.Controllers.DeckController)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
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
				buys.current = count
				buy()
			end,
			Close = function()
				menu.Unset("CardGacha")
			end,
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
