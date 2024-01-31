local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local PremiumShopMenu = require(ReplicatedStorage.Shared.React.Menus.PremiumShopMenu)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local menu = React.useContext(MenuContext)

	return React.createElement(PremiumShopMenu, {
		Visible = menu.Is("PremiumShop"),
		Close = function()
			menu.Unset("PremiumShop")
		end,
	})
end
