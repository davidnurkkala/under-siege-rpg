local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Weapons = {
	WoodenBow = {
		Name = "Wooden Bow",
		Power = 1,
	},
}

return Sift.Dictionary.map(Weapons, function(def, id)
	return Sift.Dictionary.set(def, "Id", id), id
end)
