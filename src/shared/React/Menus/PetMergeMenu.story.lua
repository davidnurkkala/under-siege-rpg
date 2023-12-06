local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetMergeMenu = require(ReplicatedStorage.Shared.React.Menus.PetMergeMenu)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Sift = require(ReplicatedStorage.Packages.Sift)

local function element(props)
	local ids = Sift.Dictionary.keys(PetDefs)
	local rand = Random.new(2)
	local owned = {}
	for x = 1, 64 do
		local id = tostring(x)
		owned[id] = {
			Id = id,
			PetId = PickRandom(ids, rand),
			Tier = rand:NextInteger(1, 3),
		}
	end

	return React.createElement(PetMergeMenu, {
		Visible = true,
		Close = function() end,
		Select = print,
		Pets = {
			Owned = owned,
			Equipped = {},
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
