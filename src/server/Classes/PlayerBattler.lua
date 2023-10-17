local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PlayerBattler = {}
PlayerBattler.__index = PlayerBattler

export type PlayerBattler = typeof(setmetatable({} :: {
	Player: Player,
	Battler: any,
}, PlayerBattler))

function PlayerBattler.new(player, battler): PlayerBattler
	local self: PlayerBattler = setmetatable({
		Player = player,
		Battler = battler,
		Trove = Trove.new(),
	}, PlayerBattler)

	self.Trove:Add(self.Battler)
	self.Trove:AddPromise(PlayerLeaving(player):andThenCall(self.Destroy, self))

	return self
end

function PlayerBattler.Destroy(self: PlayerBattler)
	self.Trove:Clean()
end

return PlayerBattler
