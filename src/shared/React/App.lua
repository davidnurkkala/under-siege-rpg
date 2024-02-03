local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local BattleResultBridge = require(ReplicatedStorage.Shared.React.BattleResult.BattleResultBridge)
local ChangeLogBoard = require(ReplicatedStorage.Shared.React.ChangeLog.ChangeLogBoard)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CutsceneController = require(ReplicatedStorage.Shared.Controllers.CutsceneController)
local DeckMenuBridge = require(ReplicatedStorage.Shared.React.Menus.DeckMenuBridge)
local DialogueBridge = require(ReplicatedStorage.Shared.React.Dialogue.DialogueBridge)
local GearMenuBridge = require(ReplicatedStorage.Shared.React.GearMenu.GearMenuBridge)
local GenericShopBridge = require(ReplicatedStorage.Shared.React.GenericShop.GenericShopBridge)
local Hud = require(ReplicatedStorage.Shared.React.Hud.Hud)
local IndicatorBridge = require(ReplicatedStorage.Shared.React.NumberPopups.IndicatorBridge)
local InventoryMenuBridge = require(ReplicatedStorage.Shared.React.Menus.InventoryMenuBridge)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LoginStreakRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.LoginStreakRewardsMenuBridge)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local MenuProvider = require(ReplicatedStorage.Shared.React.MenuContext.MenuProvider)
local OverheadLabeledBridge = require(ReplicatedStorage.Shared.React.OverheadLabeledBridge)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local PlatformProvider = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformProvider)
local PremiumShopMenuBridge = require(ReplicatedStorage.Shared.React.Menus.PremiumShopMenuBridge)
local React = require(ReplicatedStorage.Packages.React)
local RegenTimestampedBridge = require(ReplicatedStorage.Shared.React.RegenTimestampedBridge)
local SessionRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.SessionRewardsMenuBridge)
local ShoplikeBridge = require(ReplicatedStorage.Shared.React.ShoplikeBridge)
local TeleportMenuBridge = require(ReplicatedStorage.Shared.React.Teleport.TeleportMenuBridge)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local TutorialHud = require(ReplicatedStorage.Shared.React.Tutorial.TutorialHud)
local UseProperty = require(ReplicatedStorage.Shared.React.Hooks.UseProperty)
local VipMenuBridge = require(ReplicatedStorage.Shared.React.Menus.VipMenuBridge)

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

				GenericShop = React.createElement(GenericShopBridge),
				GearMenu = React.createElement(GearMenuBridge),
				TeleportMenu = React.createElement(TeleportMenuBridge),
				DeckMenu = React.createElement(DeckMenuBridge),
				InventoryMenu = React.createElement(InventoryMenuBridge),
				PremiumShopMenu = React.createElement(PremiumShopMenuBridge),
				SessionRewardsMenu = React.createElement(SessionRewardsMenuBridge),
				LoginStreakRewardsMenu = React.createElement(LoginStreakRewardsMenuBridge),
				VipMenu = React.createElement(VipMenuBridge),
				BattleResult = React.createElement(BattleResultBridge),
				Dialogue = React.createElement(DialogueBridge),

				AlphaMessage = React.createElement(alphaMessage),
			}),

			Indicators = React.createElement(IndicatorBridge),
			OverheadLabels = React.createElement(OverheadLabeledBridge),
			RegenLabels = React.createElement(RegenTimestampedBridge),
			Shoplikes = React.createElement(ShoplikeBridge),
			ChangeLogBoard = React.createElement(ChangeLogBoard),
		}),
	})
end
