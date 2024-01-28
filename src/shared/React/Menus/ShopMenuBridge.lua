local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
local ShopMenu = require(ReplicatedStorage.Shared.React.Menus.ShopMenu)

return function()
	local menu = React.useContext(MenuContext)

	return React.createElement(ShopMenu, {
		Visible = menu.Is("Shop"),
		Close = function()
			menu.Unset("Shop")
		end,
	})
end
