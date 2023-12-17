local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoginStreakController = require(ReplicatedStorage.Shared.Controllers.LoginStreakController)
local LoginStreakRewardsMenu = require(ReplicatedStorage.Shared.React.Menus.LoginStreakRewardsMenu)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local menu = React.useContext(MenuContext)
	local status, setStatus = React.useState(nil)

	React.useEffect(function()
		return LoginStreakController:ObserveStatus(setStatus)
	end, {})

	local isDataReady = status ~= nil

	return isDataReady
		and React.createElement(LoginStreakRewardsMenu, {
			Visible = menu.Is("LoginStreak"),
			AvailableRewardIndices = status.AvailableRewardIndices,
			Streak = status.Streak,
			Close = function()
				menu.Unset("LoginStreak")
			end,
			Claim = function(index)
				LoginStreakController:Claim(index)
			end,
		})
end
