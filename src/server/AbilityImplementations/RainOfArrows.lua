local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battler = require(ServerScriptService.Server.Classes.Battler)
local Damage = require(ServerScriptService.Server.Classes.Damage)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectProjectile = require(ReplicatedStorage.Shared.Effects.EffectProjectile)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local PickRandom = require(ReplicatedStorage.Shared.Util.PickRandom)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Range = require(ReplicatedStorage.Shared.Util.Range)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(def, level, battler, battle)
	return Promise.delay(0.5):andThen(function()
		local targets = battle:FilterTargets(battle:DefaultFilter(battler.TeamId))

		if #targets == 0 then return end

		targets = Sift.Array.sort(targets, function(a, b)
			if battler.Position < 0.5 then
				return a.Position < b.Position
			else
				return a.Position > b.Position
			end
		end)

		local offset = Vector3.new(8 * if battler.Position < 0.5 then 1 else -1, 32, 0)
		local index = 1

		return Promise.all(Sift.Array.map(Range(def.Count(level)), function(number)
			local target = targets[index]
			local root = target:GetRoot()

			index += 1
			if index > #targets then index = 1 end

			return Promise.delay((number - 1) * 0.3)
				:andThen(function()
					local start = root.Position + offset

					return EffectService:All(
						EffectProjectile({
							Model = ReplicatedStorage.Assets.Models.Projectiles.Arrow1,
							Start = CFrame.new(start),
							Finish = root,
							Speed = 128,
						}),
						EffectSound({
							SoundId = PickRandom({ "BowShoot1", "BowShoot2", "BowShoot3", "BowShoot4" }),
							Target = start,
						})
					)
				end)
				:andThen(function()
					local amount = def.Damage(level)
					if Battler.Is(target) then
						amount *= 0.1
					end

					battle:Damage(Damage.new(battler, target, amount))

					EffectService:All(
						EffectSound({
							SoundId = PickRandom({ "BowHit1", "BowHit2", "BowHit3", "BowHit4" }),
							Target = root,
						}),
						EffectEmission({
							Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
							ParticleCount = 2,
							Target = root,
						})
					)
				end)
		end))
	end)
end
