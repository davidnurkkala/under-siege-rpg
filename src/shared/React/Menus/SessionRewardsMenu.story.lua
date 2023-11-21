local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local SessionRewardsMenu = require(ReplicatedStorage.Shared.React.Menus.SessionRewardsMenu)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)

local function element(props)
	return React.createElement(SessionRewardsMenu, {
		Visible = true,
		Close = function() end,
		Claim = print,
		Status = {
			Timestamp = Timestamp(),
			RewardStates = { "Claimed", "Claimed", "Available", "Available", "Available" },
		},
	})
end

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(element, {}))

	return function()
		root:unmount()
	end
end
