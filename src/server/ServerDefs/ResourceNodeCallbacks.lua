local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local FaceCharacterTowards = require(ReplicatedStorage.Shared.Util.FaceCharacterTowards)
local Promise = require(ReplicatedStorage.Packages.Promise)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)

return {
	OpenChest = function(_lobbySession, model)
		EffectService:All(EffectSound({
			SoundId = "ChestOpen",
			Target = model.PrimaryPart.Position,
		}))

		return Promise.delay(0.1)
	end,
	Forage = function(_lobbySession, model)
		EffectService:All(EffectSound({
			SoundId = "Forage1",
			Target = model.PrimaryPart.Position,
		}))

		return Promise.delay(0.1)
	end,
	MineOre = function(lobbySession, model)
		local position = model.PrimaryPart.Position
		FaceCharacterTowards(lobbySession.Root, position)

		local pickaxe = ReplicatedStorage.Assets.Models.Effects.Pickaxe:Clone()
		pickaxe.Parent = lobbySession.Character

		TryNow(function()
			local constraint = Instance.new("RigidConstraint")
			constraint.Attachment0 = lobbySession.Character.RightHand.RightGripAttachment
			constraint.Attachment1 = pickaxe.Grip
			constraint.Parent = pickaxe
		end)

		lobbySession.Animator:Play("PickaxeSwingIdle")

		return Promise.race({
			lobbySession:LockDown(3.6),
			Promise.new(function(resolve, _, onCancel)
				for hitNumber = 1, 3 do
					task.wait(0.5)
					if onCancel() then return end

					EffectService:All(
						EffectEmission({
							Emitter = ReplicatedStorage.Assets.Emitters.Sparks1,
							Target = position,
							ParticleCount = 8,
						}),
						EffectSound({
							SoundId = "PickaxeHit" .. math.random(1, 5),
							Target = position,
						})
					)

					if hitNumber == 3 then
						EffectService:All(EffectSound({
							SoundId = "RockCrumble" .. math.random(1, 5),
							Target = position,
						}))
					end

					task.wait(1)
					if onCancel() then return end
				end
				resolve()
			end),
		}):finally(function()
			pickaxe:Destroy()
			lobbySession.Animator:Stop("PickaxeSwingIdle")
		end)
	end,
}
