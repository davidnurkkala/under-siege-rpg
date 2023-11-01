local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponController = require(ReplicatedStorage.Shared.Controllers.WeaponController)
local WeaponShop = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShop)
local Zoner = require(ReplicatedStorage.Shared.Classes.Zoner)

return function()
	local visible, setVisible = React.useState(false)
	local weapons, setWeapons = React.useState(nil)

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(WeaponController:ObserveWeapons(setWeapons))

		trove:Add(Zoner.new(Players.LocalPlayer, "WeaponShopZone", function(entered)
			if entered then
				setVisible(true)
			else
				setVisible(false)
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
				if not weapons then return end

				if weapons.Owned[weaponId] then
					WeaponController:EquipWeapon(weaponId)
				else
					WeaponController:UnlockWeapon(weaponId)
				end
			end,
			Close = function()
				setVisible(false)
			end,
		}),
	})
end
