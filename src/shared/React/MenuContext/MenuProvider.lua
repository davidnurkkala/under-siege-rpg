local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)

return function(props)
	local openMenu, setOpenMenu = React.useState(nil)
	local inDialogue, setInDialogue = React.useState(false)

	local interface = {
		Is = function(menu)
			return openMenu == menu
		end,
		Set = function(menu)
			setOpenMenu(function(oldMenu)
				if menu == oldMenu then
					return oldMenu
				else
					return menu
				end
			end)
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
		GetInDialogue = function()
			return inDialogue
		end,
		SetInDialogue = function(state)
			if inDialogue == state then return end
			setInDialogue(state)
		end,
	}

	return React.createElement(MenuContext.Provider, {
		value = interface,
	}, props.children)
end
