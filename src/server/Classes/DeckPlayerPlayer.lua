local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BattleService = require(ServerScriptService.Server.Services.BattleService)
local OptionsService = require(ServerScriptService.Server.Services.OptionsService)
local Range = require(ReplicatedStorage.Shared.Util.Range)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)

local DeckPlayerPlayer = {}
DeckPlayerPlayer.__index = DeckPlayerPlayer

export type DeckPlayerPlayer = typeof(setmetatable(
	{} :: {
		Deck: any,
		Player: Player,
		Trove: any,
	},
	DeckPlayerPlayer
))

function DeckPlayerPlayer.new(deck: any, player: Player): DeckPlayerPlayer
	local self: DeckPlayerPlayer = setmetatable({
		Deck = deck,
		Player = player,
		Trove = Trove.new(),
	}, DeckPlayerPlayer)

	return self
end

function DeckPlayerPlayer.ChooseCard(self: DeckPlayerPlayer)
	self.Deck:Tick()

	local choices = self.Deck:Draw(3)

	local function getAutoPick()
		for _, choice in choices do
			if choice.Id ~= "Nothing" then return choice end
		end

		return choices[1]
	end

	return self.Trove:AddPromise(OptionsService:GetOption(self.Player, "AutoPlayCards")
		:andThen(function(autoPlay)
			if autoPlay then
				return getAutoPick()
			else
				return BattleService:PromptCard(self.Player, choices):timeout(4):catch(function()
					return getAutoPick()
				end)
			end
		end)
		:andThen(function(choice)
			return self.Deck:Use(choice)
		end))
end

function DeckPlayerPlayer.Destroy(self: DeckPlayerPlayer)
	self.Trove:Clean()
end

return DeckPlayerPlayer
