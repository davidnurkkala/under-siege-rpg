local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local t = require(ReplicatedStorage.Packages.t)

local BattleService = {
	Priority = 0,
}

type BattleService = typeof(BattleService)

local BattlesByPlayer = {}
local PromisesByPlayer = {}
local BattleSlots = {}

function BattleService.PrepareBlocking(self: BattleService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "BattleService")
	self.StatusRemote = self.Comm:CreateProperty("Status", nil)

	self.Comm:CreateSignal("SurrenderRequested"):Connect(function(player)
		local battle = self:Get(player)
		if not battle then return end

		-- TODO: better way to find the player's battler?
		for _, battler in battle.Battlers do
			if battler.CharModel == player.Character then battler.Health:Set(-100) end
		end
	end)

	self.Comm:CreateSignal("CardPlayed"):Connect(function(player, cardId)
		if not t.string(cardId) then return end

		local battle = self:Get(player)
		if not battle then return end

		-- TODO: better way to find the player's battler?
		for _, battler in battle.Battlers do
			if battler.CharModel == player.Character then battle:PlayCard(battler, cardId) end
		end
	end)

	self.Comm:CreateSignal("SuppliesUpgraded"):Connect(function(player)
		local battle = self:Get(player)
		if not battle then return end

		-- TODO: better way to find the player's battler?
		for _, battler in battle.Battlers do
			if battler.CharModel == player.Character then battler:UpgradeSupplies() end
		end
	end)

	self.MessageSent = self.Comm:CreateSignal("MessageSent")
	self.RewardsDisplayed = self.Comm:CreateSignal("RewardsDisplayed")
end

function BattleService.Get(_self: BattleService, player: Player)
	return BattlesByPlayer[player]
end

function BattleService.GetPlayersFromBattle(_self: BattleService, battle)
	return Sift.Array.filter(Sift.Dictionary.keys(BattlesByPlayer), function(player)
		return BattlesByPlayer[player] == battle
	end)
end

function BattleService.Promise(_self: BattleService, player, func)
	if player:GetAttribute("IsPrestiging") then return Promise.reject(`Player {player} is currently in the prestige animation`) end

	if PromisesByPlayer[player] then
		return Promise.reject(`Player {player} is already expecting a battle`)
	else
		local promise = Promise.race({
			PlayerLeaving(player):andThenCall(Promise.reject, `Player {player} left`),
			func(),
		}):finally(function()
			PromisesByPlayer[player] = nil
		end)

		if promise:getStatus() == "Started" then PromisesByPlayer[player] = promise end

		return promise
	end
end

function BattleService.Add(self: BattleService, player: Player, battle: any)
	assert(self:Get(player) == nil, `Player {player} already has a battle`)

	BattlesByPlayer[player] = battle

	battle:Observe(function(status)
		if BattlesByPlayer[player] ~= battle then return end

		self.StatusRemote:SetFor(player, status)
	end)
end

function BattleService.Remove(self: BattleService, player: Player)
	assert(self:Get(player), `Player {player} does not have a battle to remove`)

	BattlesByPlayer[player] = nil

	self.StatusRemote:SetFor(player, nil)
end

function BattleService.ReserveSlot(_self: BattleService, callback: (Vector3) -> ()): () -> ()
	local index = 1
	while BattleSlots[index] do
		index += 1
	end
	BattleSlots[index] = true

	callback(Vector3.new(256 + 512 * index, 1024, 0))

	return function()
		BattleSlots[index] = false
	end
end

return BattleService
