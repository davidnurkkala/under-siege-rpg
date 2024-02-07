local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Damage = require(ServerScriptService.Server.Classes.Damage)
local EffectExplosion = require(ReplicatedStorage.Shared.Effects.EffectExplosion)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)

return function(def, level, battler, battle)
	local target = battle:TargetNearest({
		Position = battler.Position,
		Range = 10,
		Filter = battle:EnemyFilter(battler.TeamId),
	})

	if not target then return end

	battler.Animator:Play("MagicCastQuick", 0)

	return EffectService:ForBattle(
		battle,
		EffectProjectile({
			Model = ReplicatedStorage.Assets.Models.Projectiles.Fireball,
			Start = battler:GetRoot(),
			Finish = target:GetRoot(),
			Speed = 64,
		}),
		EffectSound({
			SoundId = "DragonRoar1",
			Target = battler:GetRoot(),
		})
	):andThen(function()
		EffectService:ForBattle(
			battle,
			EffectExplosion({ Position = target:GetRoot().Position }),
			EffectSound({ SoundId = "Explosion1", Target = target:GetRoot() })
		)

		for _, otherTarget in
			battle:TargetRadius({
				Position = target.Position,
				Radius = 0.1,
				Filter = battle:EnemyFilter(battler.TeamId),
			})
		do
			battle:Damage(Damage.new(battler, otherTarget, def.Damage(level)))
		end
	end)
end
