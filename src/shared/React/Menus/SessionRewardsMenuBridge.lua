local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
local SessionRewardsController = require(ReplicatedStorage.Shared.Controllers.SessionRewardsController)
local SessionRewardsMenu = require(ReplicatedStorage.Shared.React.Menus.SessionRewardsMenu)

return function()
	local menu = React.useContext(MenuContext)
	local status, setStatus = React.useState(nil)

	React.useEffect(function()
		return SessionRewardsController:ObserveStatus(setStatus)
	end, {})

	local isDataReady = status ~= nil

	return isDataReady
		and React.createElement(SessionRewardsMenu, {
			Visible = menu.Is("SessionRewards"),
			Status = status,
			Close = function()
				menu.Unset("SessionRewards")
			end,
			Claim = function(index)
				SessionRewardsController:Claim(index)
			end,
		})
end
