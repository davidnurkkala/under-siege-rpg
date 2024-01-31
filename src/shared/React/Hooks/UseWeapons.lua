local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local WeaponController = require(ReplicatedStorage.Shared.Controllers.WeaponController)

return function()
	local weapons, setWeapons = React.useState({})

	React.useEffect(function()
		return WeaponController:ObserveWeapons(function(weaponsIn)
			setWeapons(weaponsIn)
		end)
	end, {})

	return weapons
end
