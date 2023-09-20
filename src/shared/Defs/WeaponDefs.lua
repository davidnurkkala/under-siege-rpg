local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Weapons = {
	WoodenBow = {
		Name = "Wooden Bow",
		Power = 1,
		HoldPartName = "LeftHand",
		Animations = {
			Idle = "BowIdle",
			Shoot = "BowShoot",
		},
	},
}

return Sift.Dictionary.map(Weapons, function(def, id)
	local model = ReplicatedStorage.Assets.Weapons:FindFirstChild(id)
	assert(model, `Missing model for weapon {id}`)

	return Sift.Dictionary.merge(def, {
		Id = id,
		Model = model,
	}), id
end)
