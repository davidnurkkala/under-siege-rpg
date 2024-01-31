local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GearMenu = require(ReplicatedStorage.Shared.React.GearMenu.GearMenu)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local menu = React.useContext(MenuContext)

	return React.createElement(React.Fragment, nil, {
		GearMenu = React.createElement(GearMenu, {
			Visible = menu.Is("Gear"),
			Close = function()
				menu.Unset("Gear")
			end,
		}),
	})
end
