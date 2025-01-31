local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponController = require(ReplicatedStorage.Shared.Controllers.WeaponController)
local WeaponShop = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShop)
local Zoner = require(ReplicatedStorage.Shared.Classes.Zoner)

return function()
	local menu = React.useContext(MenuContext)
	local weapons, setWeapons = React.useState(nil)
	local shopId, setShopId = React.useState(nil)

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(WeaponController:ObserveWeapons(setWeapons))

		trove:Add(Zoner.new(Players.LocalPlayer, "WeaponShopZone", function(entered, zone)
			if entered then
				setShopId(zone:GetAttribute("ShopId"))
				menu.Set("WeaponShop")
			else
				menu.Unset("WeaponShop")
			end
		end))

		return function()
			trove:Clean()
		end
	end, {})

	local isDataReady = (weapons ~= nil) and (shopId ~= nil)

	return React.createElement(React.Fragment, nil, {
		WeaponShop = isDataReady and React.createElement(WeaponShop, {
			Visible = menu.Is("WeaponShop"),
			Weapons = weapons,
			ShopId = shopId,
			Select = function(weaponId)
				if not weapons then return end

				if weapons.Owned[weaponId] then
					WeaponController:EquipWeapon(weaponId)
				else
					WeaponController:UnlockWeapon(weaponId)
				end
			end,
			Close = function()
				menu.Unset("WeaponShop")
			end,
		}),
	})
end
