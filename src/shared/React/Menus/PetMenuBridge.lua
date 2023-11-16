local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local PetController = require(ReplicatedStorage.Shared.Controllers.PetController)
local PetMenu = require(ReplicatedStorage.Shared.React.Menus.PetMenu)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local menu = React.useContext(MenuContext)
	local pets, setPets = React.useState(nil)

	React.useEffect(function()
		return PetController:ObservePets(setPets)
	end, {})

	local isDataReady = pets ~= nil

	return isDataReady
		and React.createElement(PetMenu, {
			Visible = menu.Is("Pets"),
			Pets = pets,
			Close = function()
				menu.Unset("Pets")
			end,
			Select = function(slotId)
				return PetController:ToggleEquipped(slotId)
			end,
		})
end
