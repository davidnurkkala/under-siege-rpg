local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BasicRanged = require(ServerScriptService.Server.Classes.GoonBrains.BasicRanged)
local EffectExplosion = require(ReplicatedStorage.Shared.Effects.EffectExplosion)
local EffectService = require(ServerScriptService.Server.Services.EffectService)

local Demolitionist = {}
Demolitionist.__index = Demolitionist
setmetatable(Demolitionist, BasicRanged)

export type Demolitionist = typeof(setmetatable({} :: {}, Demolitionist))

function Demolitionist.new(args): Demolitionist
	local self = BasicRanged.new(args)
	setmetatable(self, Demolitionist)

	self.DidAttack:Connect(function(target)
		EffectService:ForBattle(self.Battle, EffectExplosion({ Position = target:GetWorldCFrame().Position }))
	end)

	return self
end

return Demolitionist
