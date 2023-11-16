local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Battlers = {
	Noob = {
		Name = "Noob",
		Reward = 1,
		Deck = {
			Peasant = 1,
		},
	},

	VikingWarrior = {
		Name = "VikingWarrior",
		Reward = 3,
		Deck = {
			Berserker = 1,
		},
	},

	VikingChief = {
		Name = "VikingChief",
		Reward = 5,
		Deck = {
			VikingWarrior = 1,
		},
	},

	VikingKing = {
		Name = "VikingKing",
		Reward = 10,
		Deck = {
			VikingWarrior = 1,
		},
	},
}

return Sift.Dictionary.map(Battlers, function(battler, id)
	local model = ReplicatedStorage.Assets.Models.Battlers:FindFirstChild(id)
	assert(model, `Battler {id} missing model`)

	return Sift.Dictionary.merge(battler, {
		Id = id,
		Model = model,
	})
end)
