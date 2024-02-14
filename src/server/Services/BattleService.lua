local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local LobbySession = require(ServerScriptService.Server.Classes.LobbySession)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local Promise = require(ReplicatedStorage.Packages.Promise)
local ServerFade = require(ServerScriptService.Server.Util.ServerFade)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
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

	self:SetUpChallenges()
end

function BattleService.SetUpChallenges(self: BattleService)
	local challengeSetsByPlayer: { [Player]: { [Player]: boolean } } = {}
	local challengeAccepted = Signal.new()

	self.Comm:BindFunction("ChallengePlayer", function(challenger, challenged)
		if not t.Instance(challenged) then return end
		if not challenged:IsA("Player") then return end

		local theirChallengeSet = challengeSetsByPlayer[challenged]
		if theirChallengeSet and theirChallengeSet[challenger] then
			challengeAccepted:Fire(challenged, challenger)

			local restoreSessions = Sift.Array.map({ challenged, challenger }, function(player)
				local session = LobbySessions.Get(player)
				if not session then return end

				local cframe = TryNow(function()
					return player.Character.PrimaryPart.CFrame
				end, CFrame.new())

				session:Destroy()

				return function()
					return LobbySession.promised(player):andThenCall(Promise.delay, 0.5):andThen(function()
						TryNow(function()
							player.Character.PrimaryPart.CFrame = cframe
						end)
					end)
				end
			end)

			local startTime = Timestamp()

			ServerFade({ challenged, challenger }, nil, function()
				local Battle = require(ServerScriptService.Server.Classes.Battle) :: any
				return Battle.fromPlayerVersusPlayer(challenged, challenger)
			end):andThen(function(battle)
				return Promise.fromEvent(battle.Finished):andThenReturn(battle)
			end):andThen(function(battle)
				return ServerFade({ challenged, challenger }, nil, function()
					local victor = battle:GetVictor()
					victor = if victor.CharModel == challenged.Character then challenged else challenger

					local duration = Timestamp() - startTime
					if duration >= 90 then
						DataService:GetSaveFile(victor):andThen(function(saveFile)
							saveFile:Update("DuelWins", function(duelWins)
								return (duelWins or 0) + 1
							end)
						end)
					end

					battle:Destroy()

					return Promise.all(Sift.Array.map(restoreSessions, function(restoreSession)
						return restoreSession()
					end))
				end)
			end)
		else
			local myChallengeSet = challengeSetsByPlayer[challenger]
			if not myChallengeSet then
				myChallengeSet = {}
				challengeSetsByPlayer[challenger] = myChallengeSet
			end

			if myChallengeSet[challenged] then return end

			myChallengeSet[challenged] = true

			Promise.race({
				Promise.delay(10),
				Promise.fromEvent(challengeAccepted, function(acceptingChallenger, acceptingChallenged)
					return acceptingChallenger == challenger and acceptingChallenged == challenged
				end),
			})
				:finally(function()
					myChallengeSet[challenged] = nil
					if Sift.Set.count(myChallengeSet) == 0 then challengeSetsByPlayer[challenger] = nil end
				end)
				:expect()
		end
	end)
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
