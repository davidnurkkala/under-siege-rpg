local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local DialogueService = require(ServerScriptService.Server.Services.DialogueService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local DialogueOneOff = {}
DialogueOneOff.__index = DialogueOneOff

export type DialogueOneOff = typeof(setmetatable(
	{} :: {
		Model: Model,
		Trove: any,
	},
	DialogueOneOff
))

function DialogueOneOff.new(model: Model): DialogueOneOff
	local text = model:GetAttribute("DialogueText")
	assert(text, `No text for dialogue one-off {model:GetFullName()}`)

	local name = model:GetAttribute("DialogueName") or model.Name
	local action = model:GetAttribute("DialogueAction") or "Talk"
	local animation = model:GetAttribute("DialogueAnimation")

	local self: DialogueOneOff = setmetatable({
		Model = model,
		Trove = Trove.new(),
	}, DialogueOneOff)

	local prompt: ProximityPrompt = self.Trove:Construct(Instance, "ProximityPrompt")
	prompt.ObjectText = name
	prompt.ActionText = action
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Triggered:Connect(function(player)
		local dialogue = DialogueService:OneOff(player, {
			Text = text,
			Animation = animation,
			Name = name,
		})
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

function DialogueOneOff.Destroy(self: DialogueOneOff)
	self.Trove:Clean()
end

return DialogueOneOff
