local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local BattleResult = require(ReplicatedStorage.Shared.React.BattleResult.BattleResult)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
local UseProperty = require(ReplicatedStorage.Shared.React.Hooks.UseProperty)

return function()
	local rewards, setRewards = React.useState(nil)
	local menu = React.useContext(MenuContext)
	local inBattle = UseProperty(BattleController.InBattle)

	React.useEffect(function()
		local connection = BattleController.RewardsDisplayed:Connect(function(rewardsIn)
			setRewards(rewardsIn)
			menu.Set("BattleResult")
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return not inBattle
		and menu.Is("BattleResult")
		and React.createElement(BattleResult, {
			Rewards = rewards,
			Close = function()
				setRewards(nil)
				menu.Unset("BattleResult")
			end,
		})
end
