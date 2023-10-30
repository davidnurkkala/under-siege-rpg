local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local WeaponShop = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShop)

local Owned = {
	SimpleBow = true,
	SimpleWand = true,
	RecurveBow = true,
}

local function element()
	local visible, setVisible = React.useState(true)
	local equipped, setEquipped = React.useState("RecurveBow")

	return React.createElement(WeaponShop, {
		Visible = visible,
		Select = function(id)
			if not Owned[id] then return end

			setEquipped(id)
		end,
		Weapons = {
			Equipped = equipped,
			Owned = Owned,
		},
	})
end

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(element))

	return function()
		root:unmount()
	end
end
