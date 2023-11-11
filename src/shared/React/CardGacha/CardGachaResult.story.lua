local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardGachaResult = require(ReplicatedStorage.Shared.React.CardGacha.CardGachaResult)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local function element(props)
	return React.createElement(CardGachaResult, {
		CardId = "Peasant",
		Close = function() end,
	})
end

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(element, {}))

	return function()
		root:unmount()
	end
end
