local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Goons = {
	Conscript = {
		ModelName = "Conscript",
		Animations = {
			Walk = "ConscriptWalk",
			Attack = "ConscriptAttack",
		},
		Speed = function()
			return 5
		end,
		Damage = function(level)
			return 1 + level
		end,
		OnUpdated = function(self, dt) end,
	},
}

return Sift.Dictionary.map(Goons, function(goon, id)
	local model = ReplicatedStorage.Assets.Models.Goons:FindFirstChild(goon.ModelName)
	assert(model, `Missing model for goon {id}`)

	return Sift.Dictionary.merge(goon, {
		Id = id,
		Model = model,
	})
end)
