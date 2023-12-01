local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattlerPromptBridge = require(ReplicatedStorage.Shared.React.BattlerPromptBridge)
local CardGachaBridge = require(ReplicatedStorage.Shared.React.CardGacha.CardGachaBridge)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local DeckMenuBridge = require(ReplicatedStorage.Shared.React.Menus.DeckMenuBridge)
local Hud = require(ReplicatedStorage.Shared.React.Hud.Hud)
local IndicatorBridge = require(ReplicatedStorage.Shared.React.NumberPopups.IndicatorBridge)
local MenuProvider = require(ReplicatedStorage.Shared.React.MenuContext.MenuProvider)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local PetGachaBridge = require(ReplicatedStorage.Shared.React.PetGacha.PetGachaBridge)
local PetMenuBridge = require(ReplicatedStorage.Shared.React.Menus.PetMenuBridge)
local React = require(ReplicatedStorage.Packages.React)
local SessionRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.SessionRewardsMenuBridge)
local WeaponShopBridge = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShopBridge)

return function()
	return React.createElement(MenuProvider, nil, {
		Main = React.createElement(Container, nil, {
			Padding = React.createElement(PaddingAll, {
				Padding = UDim.new(0.05, 0),
			}),

			Hud = React.createElement(Hud),

			WeaponShop = React.createElement(WeaponShopBridge),
			CardGacha = React.createElement(CardGachaBridge),
			PetGacha = React.createElement(PetGachaBridge),

			-- menus
			DeckMenu = React.createElement(DeckMenuBridge),
			PetMenu = React.createElement(PetMenuBridge),
			SessionRewardsMenu = React.createElement(SessionRewardsMenuBridge),
		}),

		Indicators = React.createElement(IndicatorBridge),
		BattlerPrompts = React.createElement(BattlerPromptBridge),
	})
end
