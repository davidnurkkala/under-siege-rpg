local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ObserveSignal = require(ReplicatedStorage.Shared.Util.ObserveSignal)
local Promise = require(ReplicatedStorage.Packages.Promise)
local SessionRewardDefs = require(ReplicatedStorage.Shared.Defs.SessionRewardDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)
local SessionRewardsSession = {}
SessionRewardsSession.__index = SessionRewardsSession

export type SessionRewardsSession = typeof(setmetatable(
	{} :: {
		Timestamp: number,
		RewardStates: { ("Available" | "Claimed")? },
		Changed: any,
		Promise: any,
		Player: Player,
	},
	SessionRewardsSession
))

function SessionRewardsSession.new(player: Player): SessionRewardsSession
	local self: SessionRewardsSession = setmetatable({
		Timestamp = Timestamp(),
		RewardStates = {},
		Changed = Signal.new(),
		Player = player,
	}, SessionRewardsSession)

	self.Promise = Promise.new(function(resolve, _, onCancel)
		for index, def in SessionRewardDefs do
			local elapsed = Timestamp() - self.Timestamp
			local remainder = def.Time - elapsed

			task.wait(remainder)
			if onCancel() then return end

			self:SetStatus(index, "Available")
		end
		resolve()
	end)

	return self
end

function SessionRewardsSession.SetStatus(self: SessionRewardsSession, index: number, status: ("Available" | "Claimed")?)
	if self.RewardStates[index] == status then return end

	self.RewardStates[index] = status
	self.Changed:Fire()
end

function SessionRewardsSession.ClaimReward(self: SessionRewardsSession, index: number): boolean
	if self.RewardStates[index] ~= "Available" then return false end

	self:SetStatus(index, "Claimed")

	return true
end

function SessionRewardsSession.GetStatus(self: SessionRewardsSession)
	return Sift.Dictionary.copyDeep(self.RewardStates)
end

function SessionRewardsSession.Observe(self: SessionRewardsSession, callback)
	return ObserveSignal(self.Changed, function()
		callback(self:GetStatus())
	end)
end

function SessionRewardsSession.Destroy(self: SessionRewardsSession)
	self.Promise:cancel()
end

return SessionRewardsSession
