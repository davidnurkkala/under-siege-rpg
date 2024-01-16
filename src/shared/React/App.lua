local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local BattlerPromptBridge = require(ReplicatedStorage.Shared.React.BattlerPromptBridge)
local ChangeLogBoard = require(ReplicatedStorage.Shared.React.ChangeLog.ChangeLogBoard)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local DeckMenuBridge = require(ReplicatedStorage.Shared.React.Menus.DeckMenuBridge)
local Hud = require(ReplicatedStorage.Shared.React.Hud.Hud)
local IndicatorBridge = require(ReplicatedStorage.Shared.React.NumberPopups.IndicatorBridge)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LoginStreakRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.LoginStreakRewardsMenuBridge)
local MenuProvider = require(ReplicatedStorage.Shared.React.MenuContext.MenuProvider)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local PlatformProvider = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformProvider)
local React = require(ReplicatedStorage.Packages.React)
local SessionRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.SessionRewardsMenuBridge)
local ShoplikeBridge = require(ReplicatedStorage.Shared.React.ShoplikeBridge)
local TeleportMenuBridge = require(ReplicatedStorage.Shared.React.Teleport.TeleportMenuBridge)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local TutorialHud = require(ReplicatedStorage.Shared.React.Tutorial.TutorialHud)
local UseProperty = require(ReplicatedStorage.Shared.React.Hooks.UseProperty)
local VipMenuBridge = require(ReplicatedStorage.Shared.React.Menus.VipMenuBridge)
local WeaponShopBridge = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShopBridge)

local function alphaMessage()
	local inBattle = UseProperty(BattleController.InBattle)

	return not inBattle
		and React.createElement(Label, {
			Size = UDim2.fromScale(0.3, 0.1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
			ZIndex = 64,
			Text = TextStroke("<i>This game is a WIP. Your data may be reset before full release.</i>"),
		})
end

return function()
	return React.createElement(MenuProvider, nil, {
		React.createElement(PlatformProvider, nil, {
			Hud = React.createElement(Hud),

			Main = React.createElement(Container, nil, {
				Padding = React.createElement(PaddingAll, {
					Padding = UDim.new(0.05, 0),
				}),

				TutorialHud = React.createElement(TutorialHud),

				WeaponShop = React.createElement(WeaponShopBridge),
				TeleportMenu = React.createElement(TeleportMenuBridge),
				DeckMenu = React.createElement(DeckMenuBridge),
				SessionRewardsMenu = React.createElement(SessionRewardsMenuBridge),
				LoginStreakRewardsMenu = React.createElement(LoginStreakRewardsMenuBridge),
				VipMenu = React.createElement(VipMenuBridge),

				AlphaMessage = React.createElement(alphaMessage),
			}),

			Indicators = React.createElement(IndicatorBridge),
			BattlerPrompts = React.createElement(BattlerPromptBridge),
			Shoplikes = React.createElement(ShoplikeBridge),
			ChangeLogBoard = React.createElement(ChangeLogBoard),
		}),
	})
end
