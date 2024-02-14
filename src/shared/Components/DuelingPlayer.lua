local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)

local DuelingPlayer = {}
DuelingPlayer.__index = DuelingPlayer

export type DuelingPlayer = typeof(setmetatable(
	{} :: {
		Trove: any,
	},
	DuelingPlayer
))

function DuelingPlayer.new(player: Player): DuelingPlayer
	local self: DuelingPlayer = setmetatable({
		Trove = Trove.new(),
	}, DuelingPlayer)

	if player ~= Players.LocalPlayer then self:CreatePrompt(player) end

	return self
end

function DuelingPlayer.CreatePrompt(self: DuelingPlayer, thisPlayer)
	self.Trove:Add(Observers.observeCharacter(function(player, character)
		if player ~= thisPlayer then return end

		return Observers.observeProperty(character, "PrimaryPart", function(root)
			local prompt: ProximityPrompt = Instance.new("ProximityPrompt")
			prompt.ObjectText = player.Name
			prompt.ActionText = "Challenge"
			prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
			prompt.RequiresLineOfSight = false
			prompt.MaxActivationDistance = 8
			prompt.Triggered:Connect(function()
				prompt.Enabled = false
				BattleController.ChallengePlayer(player):andThen(function()
					prompt.Enabled = true
				end)
			end)
			prompt.Parent = root

			return function()
				prompt:Destroy()
			end
		end)
	end))
end

function DuelingPlayer.Destroy(self: DuelingPlayer)
	self.Trove:Clean()
end

return DuelingPlayer
