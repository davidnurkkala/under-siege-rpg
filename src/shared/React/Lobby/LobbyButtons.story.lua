local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LobbyButtons = require(ReplicatedStorage.Shared.React.Lobby.LobbyButtons)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local function element(props)
	return React.createElement(LobbyButtons, {})
end

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(element))

	return function()
		root:unmount()
	end
end
