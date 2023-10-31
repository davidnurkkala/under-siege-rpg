local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponController = require(ReplicatedStorage.Shared.Controllers.WeaponController)
local WeaponShop = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShop)

return function()
	local visible, setVisible = React.useState(true)
	local weapons, setWeapons = React.useState(nil)

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(WeaponController:ObserveWeapons(setWeapons))

		trove:Add(task.spawn(function()
			while true do
				task.wait(0.2)
			end
		end))

		return function()
			trove:Clean()
		end
	end, {})

	return React.createElement(React.Fragment, nil, {
		WeaponShop = (weapons ~= nil) and React.createElement(WeaponShop, {
			Visible = visible,
			Weapons = weapons,
			Select = function(weaponId)
				print("Selected", weaponId)
			end,
			Close = function()
				setVisible(false)
			end,
		}),
	})
end
