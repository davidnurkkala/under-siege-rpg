local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)

local Goons = {
	Conscript = {
		ModelName = "Conscript",
		Animations = {
			Walk = "ConscriptWalk",
			Attack = "ConscriptAttack",
			Die = "GenericGoonDie",
		},
		Speed = function()
			return 5
		end,
		Damage = function(level)
			return level
		end,
		HealthMax = function(level)
			return 10 + 2 * (level - 1)
		end,
		GetOnUpdated = function()
			return StateMachine({
				{
					Name = "Walking",
					Start = function(self)
						self.Animator:Play(self.Def.Animations.Walk)
					end,
					Run = function(self, _, dt)
						self.Position += self.Direction * (self.Def.Speed() / 100) * dt
					end,
					Finish = function(self)
						self.Animator:StopHard(self.Def.Animations.Walk)
					end,
				},
			})
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
