local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Goons = {
	Peasant = {
		Name = "Peasant",
		ModelName = "Conscript",
		Brain = {
			Id = "BasicMelee",
		},
		Animations = {
			Walk = "ConscriptWalk",
			Attack = "ConscriptAttack",
			Die = "GenericGoonDie",
		},
		Sounds = {
			Hit = { "GenericStab1", "GenericStab2", "GenericStab3", "GenericStab4" },
			Death = { "MaleUgh1", "MaleUgh2" },
		},
		Size = 0.03,
		Speed = function()
			return 0.05
		end,
		Range = function()
			return 0.1
		end,
		AttackRate = function()
			return 0.75
		end,
		Damage = function(level)
			return 4 + level
		end,
		HealthMax = function(level)
			return 10 + 2 * (level - 1)
		end,
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
