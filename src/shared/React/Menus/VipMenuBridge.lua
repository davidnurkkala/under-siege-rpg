local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local ProductController = require(ReplicatedStorage.Shared.Controllers.ProductController)
local React = require(ReplicatedStorage.Packages.React)
local VipMenu = require(ReplicatedStorage.Shared.React.Menus.VipMenu)

return function()
	local menu = React.useContext(MenuContext)
	local owned, setOwned = React.useState(false)

	React.useEffect(function()
		local active = true
		task.spawn(function()
			while active do
				ProductController.GetOwnsProduct("Vip"):andThen(setOwned)
				task.wait(1)
			end
		end)

		return function()
			active = false
		end
	end, {})

	return React.createElement(VipMenu, {
		Visible = menu.Is("VIP"),
		Owned = owned,
		Close = function()
			menu.Unset("VIP")
		end,
		Buy = function()
			ProductController.PurchaseProduct("Vip")
		end,
	})
end
