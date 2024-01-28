local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Dialogue = require(ServerScriptService.Server.Classes.Dialogue)
local t = require(ReplicatedStorage.Packages.t)

local DialogueService = {
	Priority = 0,
	Dialogues = {},
}

type DialogueService = typeof(DialogueService)

function DialogueService.PrepareBlocking(self: DialogueService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "DialogueService")
	self.StateRemote = self.Comm:CreateProperty("State", nil)

	self.Comm:CreateSignal("InputChosen"):Connect(function(player: Player, index)
		if not t.integer(index) then return end

		local dialogue = self:GetDialogue(player)
		if not dialogue then return end

		dialogue:Input(index)
	end)
end

function DialogueService.StartDialogue(self: DialogueService, player: Player, dialogueId: string)
	if self.Dialogues[player] then return end

	local dialogue = Dialogue.new(player, dialogueId)

	self.Dialogues[player] = dialogue

	dialogue.State:Observe(function(state)
		self.StateRemote:SetFor(player, state)
	end)

	dialogue.Destroyed:Connect(function()
		self.Dialogues[player] = nil
	end)

	return dialogue
end

function DialogueService.GetDialogue(self: DialogueService, player: Player)
	return self.Dialogues[player]
end

return DialogueService
