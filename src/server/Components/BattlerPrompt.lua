local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battle = require(ServerScriptService.Server.Classes.Battle)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Trove = require(ReplicatedStorage.Packages.Trove)
local BattlerPrompt = {}
BattlerPrompt.__index = BattlerPrompt

export type BattlerPrompt = typeof(setmetatable({} :: {
	Model: Model,
	Id: string,
	Def: any,
}, BattlerPrompt))

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

	local prompt: ProximityPrompt = self.Trove:Construct(Instance, "ProximityPrompt")
	prompt.ObjectText = def.Name
	prompt.ActionText = "Challenge!"
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Triggered:Connect(function(player)
		local session = LobbySessions.Get(player)
		if not session then return end

		Battle.fromPlayerVersusBattler(player, self.Id, "Basic"):andThen(function(battle)
			session:Destroy()
			task.wait(5)
			battle:Destroy()
		end, warn)
	end)
	prompt.Parent = self.Model.PrimaryPart

	return self
end

function BattlerPrompt.Destroy(self: BattlerPrompt)
	self.Trove:Clean()
end

return BattlerPrompt
