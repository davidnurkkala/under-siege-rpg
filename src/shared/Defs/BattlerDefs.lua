local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Battlers = {
	Noob = {
		Name = "Noob",
		Reward = 1,
		Deck = {
			Peasant = 1,
			Recruit = 1,
		},
	},

	VikingWarrior = {
		Name = "VikingWarrior",
		Reward = 3,
		Deck = {
			Berserker = 1,
			Recruit = 1,
			VikingWarrior = 1,
		},
	},

	VikingChief = {
		Name = "VikingChief",
		Reward = 5,
		Deck = {
			Recruit = 1,
			VikingWarrior = 1,
			Hunter = 1,
			Berserker = 2,
		},
	},

	VikingKing = {
		Name = "VikingKing",
		Reward = 10,
		Deck = {
			Recruit = 1,
			Footman = 2,
			VikingWarrior = 2,
			Hunter = 3,
			Berserker = 2,
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
