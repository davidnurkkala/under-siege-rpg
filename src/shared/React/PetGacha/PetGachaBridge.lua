local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local PetController = require(ReplicatedStorage.Shared.Controllers.PetController)
local PetGacha = require(ReplicatedStorage.Shared.React.PetGacha.PetGacha)
local PetGachaResult = require(ReplicatedStorage.Shared.React.PetGacha.PetGachaResult)
local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zoner = require(ReplicatedStorage.Shared.Classes.Zoner)

return function()
	local menu = React.useContext(MenuContext)
	local currency, setCurrency = React.useState(nil)
	local gachaId, setGachaId = React.useState(nil)
	local state, setState = React.useState("Shop")
	local resultPetId = React.useRef(nil)

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
			Buy = function()
				setState("Waiting")
				PetController:HatchPetFromGacha(gachaId):andThen(function(success, petId)
					if not success then
						setState("Shop")
						return
					end

					resultPetId.current = petId
					setState("Result")
				end)
			end,
			Close = function()
				menu.Unset("PetGacha")
			end,
		}),

		Result = (state == "Result") and React.createElement(PetGachaResult, {
			PetId = resultPetId.current,
			Close = function()
				setState("Shop")
			end,
		}),
	})
end
