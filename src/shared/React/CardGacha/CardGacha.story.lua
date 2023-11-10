local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardGacha = require(ReplicatedStorage.Shared.React.CardGacha.CardGacha)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local function element(props)
	return React.createElement(CardGacha, {
		GachaId = "World1Goons",
		Visible = true,
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
