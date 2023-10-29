local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local WeaponShop = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShop)

local function element()
	local visible, setVisible = React.useState(true)

	return React.createElement(WeaponShop, {
		Visible = visible,
	})
end

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(element))

	return function()
		root:unmount()
	end
end
