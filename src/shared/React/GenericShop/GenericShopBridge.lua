local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GenericShop = require(ReplicatedStorage.Shared.React.GenericShop.GenericShop)
local GenericShopController = require(ReplicatedStorage.Shared.Controllers.GenericShopController)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zoner = require(ReplicatedStorage.Shared.Classes.Zoner)

return function()
	local menu = React.useContext(MenuContext)
	local shopId, setShopId = React.useState(nil)

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(Zoner.new(Players.LocalPlayer, "ShopZone", function(entered, zone)
			if entered then
				setShopId(zone:GetAttribute("ShopId"))
				menu.Set("GenericShop")
			else
				menu.Unset("GenericShop")
			end
		end))

		trove:Connect(GenericShopController.ShopOpened, function(shopIdIn)
			menu.Set("GenericShop")
			setShopId(shopIdIn)
		end)

		return function()
			trove:Clean()
		end
	end, {})

	local isDataReady = (shopId ~= nil)

	return React.createElement(React.Fragment, nil, {
		GenericShop = isDataReady and React.createElement(GenericShop, {
			Visible = menu.Is("GenericShop"),
			ShopId = shopId,
			Close = function()
				menu.Unset("GenericShop")
			end,
		}),
	})
end
