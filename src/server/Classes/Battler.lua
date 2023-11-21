local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local Deck = require(ServerScriptService.Server.Classes.Deck)
local DeckPlayerRandom = require(ServerScriptService.Server.Classes.DeckPlayerRandom)
local EffectBattlerCollapse = require(ReplicatedStorage.Shared.Effects.EffectBattlerCollapse)
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local Health = require(ReplicatedStorage.Shared.Classes.Health)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Battler = {}
Battler.__index = Battler

type DeckPlayer = {
	ChooseCard: (DeckPlayer) -> any,
} | any

export type Battler = typeof(setmetatable(
	{} :: {
		Health: Health.Health,
		Position: number,
		Direction: number,
		BaseModel: Model,
		CharModel: Model,
		Destroyed: any,
		Battle: any?,
		TeamId: string,
		Active: boolean,
		DeckPlayer: DeckPlayer,
		Animator: Animator.Animator,
	},
	Battler
))

function Battler.new(args: {
	HealthMax: number,
	Position: number,
	Direction: number,
	BaseModel: Model,
	CharModel: Model,
	TeamId: string,
	DeckPlayer: DeckPlayer,
	Animator: Animator.Animator,
}): Battler
	local self: Battler = setmetatable({
		Health = Health.new(args.HealthMax),
		Position = args.Position,
		Direction = args.Direction,
		BaseModel = args.BaseModel,
		CharModel = args.CharModel,
		TeamId = args.TeamId,
		DeckPlayer = args.DeckPlayer,
		Animator = args.Animator,
		Destroyed = Signal.new(),
		Changed = Signal.new(),
		Active = true,
	}, Battler)

	self.Health:Observe(function()
		self.Changed:Fire(self:GetStatus())
	end)

	return self
end

function Battler.fromBattlerId(battlerId: string, position: number, direction: number)
	local def = BattlerDefs[battlerId]
	assert(def, `No def found for battler id {battlerId}`)

	local base = ReplicatedStorage.Assets.Models.Bases.Basic:Clone()

	local char = def.Model:Clone()
	char.Parent = workspace

	local battler = Battler.new({
		BaseModel = base,
		CharModel = char,
		Position = position,
		Direction = direction,
		TeamId = `NON_PLAYER_{battlerId}`,
		DeckPlayer = DeckPlayerRandom.new(Deck.new(def.Deck)),
		Animator = Animator.new(char.Humanoid),
		HealthMax = 100,
	})

	battler.Destroyed:Connect(function()
		char:Destroy()
	end)

	return battler
end

function Battler.DefeatAnimation(self: Battler)
	self.Animator:Play("GenericBattlerDie", 0)

	EffectService:All(EffectBattlerCollapse({
		CharModel = self.CharModel,
		BaseModel = self.BaseModel,
	}))

	return Promise.delay(2.5)
end

function Battler.GetWorldCFrame(self: Battler)
	local cframe = self.BaseModel:GetBoundingBox()
	return cframe
end

function Battler.GetRoot(self: Battler): BasePart
	local root = self.CharModel.PrimaryPart
	assert(root, `No primary part in char root`)
	return root
end

function Battler.SetBattle(self: Battler, battle)
	self.Battle = battle
end

function Battler.GetBattle(self: Battler)
	return self.Battle
end

function Battler.GetStatus(self: Battler)
	return {
		BaseModel = self.BaseModel,
		CharModel = self.CharModel,
		Health = self.Health:Get(),
		HealthMax = self.Health.Max,
	}
end

function Battler.Observe(self: Battler, callback)
	local connection = self.Changed:Connect(callback)
	callback(self:GetStatus())
	return connection
end

function Battler.IsActive(self: Battler)
	if not self.Active then return false end

	return self.Health:Get() > 0
end

function Battler.Destroy(self: Battler)
	self.Active = false
	self.Destroyed:Fire()
end

return Battler
