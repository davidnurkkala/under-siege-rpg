local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardGachaBridge = require(ReplicatedStorage.Shared.React.CardGacha.CardGachaBridge)
local Hud = require(ReplicatedStorage.Shared.React.Hud.Hud)
local MenuProvider = require(ReplicatedStorage.Shared.React.MenuContext.MenuProvider)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local PetGachaBridge = require(ReplicatedStorage.Shared.React.PetGacha.PetGachaBridge)
local PetMenuBridge = require(ReplicatedStorage.Shared.React.Menus.PetMenuBridge)
local React = require(ReplicatedStorage.Packages.React)
local WeaponShopBridge = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShopBridge)

return function()
	return React.createElement(MenuProvider, nil, {
		Padding = React.createElement(PaddingAll, {
			Padding = UDim.new(0.05, 0),
		}),

		Hud = React.createElement(Hud),

		WeaponShop = React.createElement(WeaponShopBridge),
		CardGacha = React.createElement(CardGachaBridge),
		PetGacha = React.createElement(PetGachaBridge),

		-- menus
		PetMenu = React.createElement(PetMenuBridge),
	})
end
