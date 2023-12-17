local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattlerPromptBridge = require(ReplicatedStorage.Shared.React.BattlerPromptBridge)
local CardGachaBridge = require(ReplicatedStorage.Shared.React.CardGacha.CardGachaBridge)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local DeckMenuBridge = require(ReplicatedStorage.Shared.React.Menus.DeckMenuBridge)
local Hud = require(ReplicatedStorage.Shared.React.Hud.Hud)
local IndicatorBridge = require(ReplicatedStorage.Shared.React.NumberPopups.IndicatorBridge)
local LoginStreakRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.LoginStreakRewardsMenuBridge)
local MenuProvider = require(ReplicatedStorage.Shared.React.MenuContext.MenuProvider)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local PetGachaBridge = require(ReplicatedStorage.Shared.React.PetGacha.PetGachaBridge)
local PetMenuBridge = require(ReplicatedStorage.Shared.React.Menus.PetMenuBridge)
local PetMergeMenuBridge = require(ReplicatedStorage.Shared.React.Menus.PetMergeMenuBridge)
local PlatformProvider = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformProvider)
local React = require(ReplicatedStorage.Packages.React)
local SessionRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.SessionRewardsMenuBridge)
local TeleportMenuBridge = require(ReplicatedStorage.Shared.React.Teleport.TeleportMenuBridge)
local TutorialHud = require(ReplicatedStorage.Shared.React.Tutorial.TutorialHud)
local WeaponShopBridge = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShopBridge)

return function()
	return React.createElement(MenuProvider, nil, {
		React.createElement(PlatformProvider, nil, {
			Main = React.createElement(Container, nil, {
				Padding = React.createElement(PaddingAll, {
					Padding = UDim.new(0.05, 0),
				}),

				Hud = React.createElement(Hud),
				TutorialHud = React.createElement(TutorialHud),

				WeaponShop = React.createElement(WeaponShopBridge),
				CardGacha = React.createElement(CardGachaBridge),
				PetGacha = React.createElement(PetGachaBridge),
				PetMerge = React.createElement(PetMergeMenuBridge),
				TeleportMenu = React.createElement(TeleportMenuBridge),
				DeckMenu = React.createElement(DeckMenuBridge),
				PetMenu = React.createElement(PetMenuBridge),
				SessionRewardsMenu = React.createElement(SessionRewardsMenuBridge),
				LoginStreakRewardsMenu = React.createElement(LoginStreakRewardsMenuBridge),
			}),

			Indicators = React.createElement(IndicatorBridge),
			BattlerPrompts = React.createElement(BattlerPromptBridge),
		}),
	})
end
