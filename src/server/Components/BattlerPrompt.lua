local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battle = require(ServerScriptService.Server.Classes.Battle)
local BattleHelper = require(ServerScriptService.Server.Util.BattleHelper)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local LobbySession = require(ServerScriptService.Server.Classes.LobbySession)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Promise = require(ReplicatedStorage.Packages.Promise)
local ServerFade = require(ServerScriptService.Server.Util.ServerFade)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local BattlerPrompt = {}
BattlerPrompt.__index = BattlerPrompt

export type BattlerPrompt = typeof(setmetatable(
	{} :: {
		Model: Model,
		Id: string,
		Def: any,
	},
	BattlerPrompt
))

function BattlerPrompt.new(model: Model): BattlerPrompt
	local id = model:GetAttribute("BattlerId")
	assert(id, `No id for Battler {model:GetFullName()}`)

	local def = BattlerDefs[id]
	assert(def, `No def for Battler id {id}`)

	local self: BattlerPrompt = setmetatable({
		Model = model,
		Id = id,
		Def = def,
		Trove = Trove.new(),
	}, BattlerPrompt)

	Promise.try(function()
		((self.Model :: Model):FindFirstChild("Humanoid") :: Humanoid).DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end):catch(warn)

	local prompt: ProximityPrompt = self.Trove:Construct(Instance, "ProximityPrompt")
	prompt.ObjectText = def.Name
	prompt.ActionText = "Challenge!"
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Triggered:Connect(function(player)
		BattleHelper.FadeToBattle(player, self.Id, model:GetPivot() + Vector3.new(0, 4, 0))
	end)
	prompt.Parent = self.Model.PrimaryPart

	return self
end

function BattlerPrompt.Destroy(self: BattlerPrompt)
	self.Trove:Clean()
end

return BattlerPrompt
