local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardGacha = require(ReplicatedStorage.Shared.React.CardGacha.CardGacha)
local CardGachaDefs = require(ReplicatedStorage.Shared.Defs.CardGachaDefs)
local CardGachaResult = require(ReplicatedStorage.Shared.React.CardGacha.CardGachaResult)
local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local DeckController = require(ReplicatedStorage.Shared.Controllers.DeckController)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local MultiRollPrompt = require(ReplicatedStorage.Shared.React.Common.MultiRollPrompt)
local ProductController = require(ReplicatedStorage.Shared.Controllers.ProductController)
local QuestController = require(ReplicatedStorage.Shared.Controllers.QuestController)
local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zoner = require(ReplicatedStorage.Shared.Classes.Zoner)

return function()
	local menu = React.useContext(MenuContext)
	local currency, setCurrency = React.useState(nil)
	local gachaId, setGachaId = React.useState(nil)
	local state, setState = React.useState("Shop")
	local results, setResults = React.useState(nil)
	local countRef = React.useRef(1)

	local buy = React.useCallback(function(count)
		setState("Waiting")
		DeckController:DrawCardFromGacha(gachaId, count):andThen(function(success, resultsIn)
			if not success then
				setState("Shop")
				return
			end

			setResults(resultsIn)
			setState("Result")
		end)
	end, { gachaId })

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(CurrencyController:ObserveCurrency(setCurrency))

		trove:Add(Zoner.new(Players.LocalPlayer, "CardGachaZone", function(entered, zone)
			if entered then
				local id = zone:GetAttribute("GachaId")
				local def = CardGachaDefs[id]
				if not def then return end

				if def.QuestRequirement then
					if not QuestController:IsQuestComplete(def.QuestRequirement) then return end
				end

				setGachaId(id)
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
				countRef.current = count

				if count > 1 then
					setState(nil)
					ProductController.GetOwnsProduct("MultiRoll")
						:andThen(function(owned)
							if owned then
								buy(count)
							else
								setState("Sell")
							end
						end)
						:catch(function()
							setState("Shop")
						end)
				else
					buy(1)
				end
			end,
			Close = function()
				menu.Unset("CardGacha")
			end,
		}),

		Sell = React.createElement(MultiRollPrompt, {
			Visible = state == "Sell",
			Once = function()
				buy(countRef.current)
			end,
			Close = function()
				setState("Shop")
			end,
		}),

		Result = (state == "Result") and React.createElement(CardGachaResult, {
			Results = results,
			Close = function()
				setState("Shop")
			end,
		}),
	})
end
