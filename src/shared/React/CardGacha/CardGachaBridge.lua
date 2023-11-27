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
	local resultCardId = React.useRef(nil)
	local resultCardCount = React.useRef(nil)

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
			Buy = function()
				setState("Waiting")
				DeckController:DrawCardFromGacha(gachaId):andThen(function(success, cardId, cardCount)
					if not success then
						setState("Shop")
						return
					end

					resultCardId.current = cardId
					resultCardCount.current = cardCount
					setState("Result")
				end)
			end,
			Close = function()
				menu.Unset("CardGacha")
			end,
		}),

		Result = (state == "Result") and React.createElement(CardGachaResult, {
			CardId = resultCardId.current,
			CardCount = resultCardCount.current,
			Close = function()
				setState("Shop")
			end,
		}),
	})
end
