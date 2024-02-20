local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local EffectEmission = require(ReplicatedStorage.Shared.Effects.EffectEmission)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local EffectShakeModel = require(ReplicatedStorage.Shared.Effects.EffectShakeModel)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local RewardHelper = require(ServerScriptService.Server.Util.RewardHelper)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Radius = 32

local TrainingDummy = {}
TrainingDummy.__index = TrainingDummy

export type TrainingDummy = typeof(setmetatable({} :: {}, TrainingDummy))

function TrainingDummy.new(model: Model): TrainingDummy
	local self: TrainingDummy = setmetatable({
		Model = model,
		Root = model.PrimaryPart,
		Trove = Trove.new(),
	}, TrainingDummy)

	self.Trove:Add(task.spawn(function()
		while true do
			task.wait(0.25)

			for _, player in Players:GetPlayers() do
				local session = LobbySessions.Get(player)
				if not session then continue end

				if player:DistanceFromCharacter(self:GetPosition()) <= Radius then
					session.WeaponTarget:Set(self)
				else
					if session.WeaponTarget:Get() == self then session.WeaponTarget:Set(nil) end
				end
			end
		end
	end))

	return self
end

function TrainingDummy:GetRoot()
	return self.Root
end

function TrainingDummy:GetPosition()
	return self.Root.Core.WorldPosition
end

function TrainingDummy.OnHit(self: TrainingDummy, lobbySession: any)
	EffectService:All(
		EffectEmission({
			Emitter = ReplicatedStorage.Assets.Emitters.Impact1,
			ParticleCount = 2,
			Target = self:GetPosition(),
		}),
		EffectShakeModel({
			Model = self.Model,
		})
	)

	return RewardHelper.GiveReward(lobbySession.Player, { Type = "Currency", CurrencyType = "Glory", Amount = 1 }):andThen(function(reward)
		GuiEffectService.IndicatorRequestedRemote:Fire(lobbySession.Player, {
			Text = `+{reward.Amount // 1}`,
			Image = CurrencyDefs.Glory.Image,
			Start = self:GetPosition(),
			EndGui = "GuiPanelGlory",
		})
	end)
end

function TrainingDummy.Destroy(self: TrainingDummy)
	self.Trove:Clean()
end

return TrainingDummy
