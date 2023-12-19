local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local AnimationDefs = require(ReplicatedStorage.Shared.Defs.AnimationDefs)
local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectSound = require(ReplicatedStorage.Shared.Effects.EffectSound)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(args: {
	Player: Player,
})
	return function()
		return script.Name, args, Promise.delay(3)
	end, function()
		local char = args.Player.Character
		if not char then return end

		return Promise.all({
			EffectController:Effect(EffectSound({
				SoundId = "PrestigeSound",
				Target = char.PrimaryPart,
			})),
			Promise.try(function()
				local effect = ReplicatedStorage.Assets.Models.Effects.PrestigeCharge:Clone()
				effect.Parent = workspace.Effects

				return Promise.all({
					Animate(1.3, function()
						effect:PivotTo(char.PrimaryPart.CFrame)
					end):andThen(function()
						return EffectController:Effect(EffectEmission({
							Emitter = ReplicatedStorage.Assets.Emitters.PrestigeBurst1,
							Target = char.UpperTorso.BodyFrontAttachment,
							ParticleCount = 1,
						}))
					end),
					Promise.delay(0.95):andThen(function()
						effect.Root.Emitter.Enabled = false
					end),
				}):finally(function()
					effect:Destroy()
				end)
			end),
			Promise.try(function()
				if args.Player ~= Players.LocalPlayer then return end

				local track = char:FindFirstChild("Humanoid"):LoadAnimation(AnimationDefs.Prestige)
				track:Play(0)

				local mover = Instance.new("BodyVelocity")
				mover.MaxForce = Vector3.one * 1e9
				mover.Velocity = Vector3.new(0, 2, 0)
				mover.Parent = char.PrimaryPart

				return Promise.delay(3):finally(function()
					track:Stop(0.5)
					mover:Destroy()
				end)
			end),
		})
	end
end
