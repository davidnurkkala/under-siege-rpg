local ServerScriptService = game:GetService("ServerScriptService")

local BasicMelee = require(ServerScriptService.Server.Classes.GoonBrains.BasicMelee)

local HitAndRunMelee = {}
HitAndRunMelee.__index = HitAndRunMelee
setmetatable(HitAndRunMelee, BasicMelee)

export type HitAndRunMelee = typeof(setmetatable({} :: {}, HitAndRunMelee))

function HitAndRunMelee.new(args): HitAndRunMelee
	local self = BasicMelee.new(args)
	setmetatable(self, HitAndRunMelee)

	return self
end

function HitAndRunMelee.SetUpStateMachine(self: HitAndRunMelee)
	BasicMelee.SetUpStateMachine(self :: any)

	self.StateMachine:RegisterStates({
		{
			Name = "Walking",
			Start = function()
				self.Goon.Animator:Play(self.Goon.Def.Animations.Walk)
			end,
			Run = function(_, dt)
				self:Walk(dt)

				if self.AttackCooldown:IsReady() then
					if self:GetTarget() then return "Attacking" end
				else
					return "Retreating"
				end

				return
			end,
			Finish = function()
				self.Goon.Animator:StopHard(self.Goon.Def.Animations.Walk)
			end,
		},
		{
			Name = "Retreating",
			Start = function(data)
				data.RemoveSlow = self.Goon.Stats.Speed:Modify("Percent", function(amount)
					return amount - 0.5
				end)
				self.Goon.Direction *= -1
				self.Goon.Animator:Play(self.Goon.Def.Animations.Walk)
			end,
			Run = function(_, dt)
				self:Walk(dt)

				if self.AttackCooldown:IsReady() then return "Walking" end

				return
			end,
			Finish = function(data)
				data.RemoveSlow()
				self.Goon.Direction *= -1
				self.Goon.Animator:StopHard(self.Goon.Def.Animations.Walk)
			end,
		},
	})
end

return HitAndRunMelee
