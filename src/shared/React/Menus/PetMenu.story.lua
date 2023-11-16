local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetMenu = require(ReplicatedStorage.Shared.React.Menus.PetMenu)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local function element(props)
	return React.createElement(PetMenu, {
		Visible = true,
		Close = function() end,
		Select = print,
		Pets = {
			Owned = {
				A = { Id = "A", PetId = "Wolfy", Tier = 1 },
				B = { Id = "B", PetId = "Doggy", Tier = 1 },
				C = { Id = "C", PetId = "Bunny", Tier = 1 },
				D = { Id = "D", PetId = "Bunny", Tier = 2 },
			},
			Equipped = {
				A = true,
				D = true,
			},
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
