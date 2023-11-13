local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetGacha = require(ReplicatedStorage.Shared.React.PetGacha.PetGacha)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local function element(props)
	return React.createElement(PetGacha, {
		GachaId = "World1Pets",
		Visible = true,
		Close = function() end,
		Buy = function() end,
		Wallet = {
			Secondary = 50,
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
