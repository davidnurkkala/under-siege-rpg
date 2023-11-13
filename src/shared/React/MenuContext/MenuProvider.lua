local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)

return function(props)
	local openMenu, setOpenMenu = React.useState(nil)

	local interface = {
		Is = function(menu)
			return openMenu == menu
		end,
		Set = function(menu)
			setOpenMenu(menu)
		end,
		Unset = function(menu)
			setOpenMenu(function(oldMenu)
				if menu == oldMenu then
					return nil
				else
					return oldMenu
				end
			end)
		end,
	}

	return React.createElement(MenuContext.Provider, {
		value = interface,
	}, props.children)
end
