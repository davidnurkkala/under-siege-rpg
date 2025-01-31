local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local DialogueService = require(ServerScriptService.Server.Services.DialogueService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local DialoguePrompt = {}
DialoguePrompt.__index = DialoguePrompt

export type DialoguePrompt = typeof(setmetatable(
	{} :: {
		Model: Model,
		Id: string,
		Def: any,
	},
	DialoguePrompt
))

function DialoguePrompt.new(model: Model): DialoguePrompt
	local id = model:GetAttribute("DialogueId")
	assert(id, `No id for dialogue prompt {model:GetFullName()}`)

	local name = model:GetAttribute("DialogueName") or model.Name
	local action = model:GetAttribute("DialogueAction") or "Talk"

	local self: DialoguePrompt = setmetatable({
		Model = model,
		Id = id,
		Trove = Trove.new(),
	}, DialoguePrompt)

	local prompt: ProximityPrompt = self.Trove:Construct(Instance, "ProximityPrompt")
	prompt.ObjectText = name
	prompt.ActionText = action
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Triggered:Connect(function(player)
		local dialogue = DialogueService:StartDialogue(player, self.Id)
		if not dialogue then return end

		dialogue:SetModel(self.Model)

		local timeAway = 0

		Promise.race({
			Promise.fromEvent(dialogue.Destroyed),
			Promise.fromEvent(RunService.Heartbeat, function(dt)
				local inLobby = LobbySessions.Get(player) ~= nil

				local cframe = model:GetBoundingBox()
				local inRange = player:DistanceFromCharacter(cframe.Position) < prompt.MaxActivationDistance

				if inRange or not inLobby then
					timeAway = 0
					return false
				else
					timeAway += dt
					return timeAway > 1
				end
			end):andThen(function()
				dialogue:Destroy()
			end),
		})
	end)
	prompt.Parent = self.Model.PrimaryPart

	return self
end

function DialoguePrompt.Destroy(self: DialoguePrompt)
	self.Trove:Clean()
end

return DialoguePrompt
