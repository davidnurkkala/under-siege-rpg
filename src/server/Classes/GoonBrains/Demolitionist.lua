local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BasicRanged = require(ServerScriptService.Server.Classes.GoonBrains.BasicRanged)
local Damage = require(ServerScriptService.Server.Classes.Damage)
local EffectExplosion = require(ReplicatedStorage.Shared.Effects.EffectExplosion)
local EffectService = require(ServerScriptService.Server.Services.EffectService)

local Demolitionist = {}
Demolitionist.__index = Demolitionist
setmetatable(Demolitionist, BasicRanged)

export type Demolitionist = typeof(setmetatable({} :: {}, Demolitionist))

function Demolitionist.new(args): Demolitionist
	local self = BasicRanged.new(args)
	self.KeepDistanceRatio = 1
	setmetatable(self, Demolitionist)

	self.DidAttack:Connect(function(target)
		EffectService:ForBattle(self.Battle, EffectExplosion({ Position = target:GetRoot().Position }))

		for _, otherTarget in
			self.Battle:TargetRadius({
				Position = target.Position,
				Radius = 0.1,
				Filter = self.Battle:EnemyFilter(self.Goon.TeamId),
			})
		do
			if otherTarget == target then continue end

			self.Battle:Damage(Damage.new(self.Goon, otherTarget, self.Goon:GetStat("Damage")))
		end
	end)

	return self
end

return Demolitionist
