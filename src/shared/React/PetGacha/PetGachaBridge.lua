local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local PetController = require(ReplicatedStorage.Shared.Controllers.PetController)
local PetGacha = require(ReplicatedStorage.Shared.React.PetGacha.PetGacha)
local PetGachaDefs = require(ReplicatedStorage.Shared.Defs.PetGachaDefs)
local PetGachaResult = require(ReplicatedStorage.Shared.React.PetGacha.PetGachaResult)
local ProductController = require(ReplicatedStorage.Shared.Controllers.ProductController)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local Zoner = require(ReplicatedStorage.Shared.Classes.Zoner)

return function()
	local menu = React.useContext(MenuContext)
	local currency, setCurrency = React.useState(nil)
	local gachaId, setGachaId = React.useState(nil)
	local state, setState = React.useState("Shop")
	local results, setResults = React.useState(nil)

	local buy = React.useCallback(function(count)
		setState("Waiting")
		PetController:HatchPetFromGacha(gachaId, count):andThen(function(success, resultsIn)
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

		trove:Add(Zoner.new(Players.LocalPlayer, "PetGachaZone", function(entered, zone)
			if entered then
				setGachaId(zone:GetAttribute("GachaId"))
				menu.Set("PetGacha")
			else
				menu.Unset("PetGacha")
			end
		end))

		return function()
			trove:Clean()
		end
	end, {})

	local isDataReady = (gachaId ~= nil) and (currency ~= nil)

	return React.createElement(React.Fragment, nil, {
		Gacha = isDataReady and React.createElement(PetGacha, {
			Visible = menu.Is("PetGacha") and (state == "Shop"),
			GachaId = gachaId,
			Wallet = currency,
			Buy = function(count)
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
				menu.Unset("PetGacha")
			end,
		}),

		Sell = React.createElement(PromptWindow, {
			Visible = state == "Sell",
			HeaderText = TextStroke("Buy Multi-hatch"),
			Text = TextStroke("Multi-hatch can be bought by itself, but it's free for Premium users!"),
			TextSize = 0.5,
			[React.Event.Activated] = function()
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

		Result = (state == "Result") and React.createElement(PetGachaResult, {
			Results = results,
			EggId = TryNow(function()
				return PetGachaDefs[gachaId].EggId
			end, "World1"),
			Close = function()
				setState("Shop")
			end,
		}),
	})
end
