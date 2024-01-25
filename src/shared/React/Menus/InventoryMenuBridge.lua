local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryMenu = require(ReplicatedStorage.Shared.React.Menus.InventoryMenu)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local menu = React.useContext(MenuContext)

	return React.createElement(InventoryMenu, {
		Visible = menu.Is("Inventory"),
		Close = function()
			menu.Unset("Inventory")
		end,
	})
end
