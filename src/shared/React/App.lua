local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local BattleResultBridge = require(ReplicatedStorage.Shared.React.BattleResult.BattleResultBridge)
local ChangeLogMenu = require(ReplicatedStorage.Shared.React.ChangeLog.ChangeLogMenu)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local DeckMenuBridge = require(ReplicatedStorage.Shared.React.Menus.DeckMenuBridge)
local DialogueBridge = require(ReplicatedStorage.Shared.React.Dialogue.DialogueBridge)
local GameController = require(ReplicatedStorage.Shared.Controllers.GameController)
local GearMenuBridge = require(ReplicatedStorage.Shared.React.GearMenu.GearMenuBridge)
local GenericShopBridge = require(ReplicatedStorage.Shared.React.GenericShop.GenericShopBridge)
local GuideBridge = require(ReplicatedStorage.Shared.React.GuideBridge)
local Hud = require(ReplicatedStorage.Shared.React.Hud.Hud)
local IndicatorBridge = require(ReplicatedStorage.Shared.React.NumberPopups.IndicatorBridge)
local InventoryMenuBridge = require(ReplicatedStorage.Shared.React.Menus.InventoryMenuBridge)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LoginStreakRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.LoginStreakRewardsMenuBridge)
local MenuProvider = require(ReplicatedStorage.Shared.React.MenuContext.MenuProvider)
local OverheadLabeledBridge = require(ReplicatedStorage.Shared.React.OverheadLabeledBridge)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local PlatformProvider = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformProvider)
local PremiumShopMenuBridge = require(ReplicatedStorage.Shared.React.Menus.PremiumShopMenuBridge)
local QuestMenu = require(ReplicatedStorage.Shared.React.QuestMenu.QuestMenu)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RegenTimestampedBridge = require(ReplicatedStorage.Shared.React.RegenTimestampedBridge)
local SessionRewardsMenuBridge = require(ReplicatedStorage.Shared.React.Menus.SessionRewardsMenuBridge)
local ShoplikeBridge = require(ReplicatedStorage.Shared.React.ShoplikeBridge)
local StartScreen = require(ReplicatedStorage.Shared.React.StartScreen.StartScreen)
local TeleportMenuBridge = require(ReplicatedStorage.Shared.React.Teleport.TeleportMenuBridge)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local TutorialHud = require(ReplicatedStorage.Shared.React.Tutorial.TutorialHud)
local UseProperty = require(ReplicatedStorage.Shared.React.Hooks.UseProperty)
local VipMenuBridge = require(ReplicatedStorage.Shared.React.Menus.VipMenuBridge)

local function betaMessage()
	local inBattle = UseProperty(BattleController.InBattle)

	return not inBattle
		and React.createElement(Label, {
			Size = UDim2.new(1, 0, 0, 12),
			Position = UDim2.new(0.5, 0, 0, 4),
			AnchorPoint = Vector2.new(0.5, 0),
			ZIndex = 64,
			Text = TextStroke("<i>This game is a WIP. Content may be buggy or incomplete. Data will <b>not</b> be reset at this point.</i>"),
		})
end

return function(props: {
	DialogueContainer: ScreenGui,
})
	local startScreen, setStartScreen = React.useState(true)

	return React.createElement(MenuProvider, nil, {
		React.createElement(PlatformProvider, nil, {
			GuiGuide = React.createElement(GuideBridge),

			Dialogue = props.DialogueContainer and ReactRoblox.createPortal({
				Padding = React.createElement(PaddingAll, {
					Padding = UDim.new(0.05, 0),
				}),

				Dialogue = React.createElement(DialogueBridge),
			}, props.DialogueContainer),

			StartScreen = startScreen and React.createElement(StartScreen, {
				Close = function()
					GameController.Play():andThen(function()
						setStartScreen(false)
					end)
				end,
			}),

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
				ChangeLogMenu = React.createElement(ChangeLogMenu),
				QuestMenu = React.createElement(QuestMenu),
			}),

			BetaMessage = React.createElement(betaMessage),
			Indicators = React.createElement(IndicatorBridge),
			OverheadLabels = React.createElement(OverheadLabeledBridge),
			RegenLabels = React.createElement(RegenTimestampedBridge),
			Shoplikes = React.createElement(ShoplikeBridge),
		}),
	})
end
