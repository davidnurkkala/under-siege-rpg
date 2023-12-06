local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local RewardHelper = require(ServerScriptService.Server.Util.RewardHelper)
local SessionRewardDefs = require(ReplicatedStorage.Shared.Defs.SessionRewardDefs)
local SessionRewardsSession = require(ServerScriptService.Server.Classes.SessionRewardsSession)
local t = require(ReplicatedStorage.Packages.t)

local SessionRewardsService = {
	Priority = 0,
}

type SessionRewardsService = typeof(SessionRewardsService)

local SessionsByPlayer = {}

function SessionRewardsService.PrepareBlocking(self: SessionRewardsService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "SessionRewardsService")

	self.StatusRemote = self.Comm:CreateProperty("Status", {})

	Observers.observePlayer(function(player)
		local session = SessionRewardsSession.new(player)

		session:Observe(function(status)
			self.StatusRemote:SetFor(player, status)
		end)

		SessionsByPlayer[player] = session

		return function()
			session:Destroy()
			SessionsByPlayer[player] = nil
		end
	end)

	self.ClaimRequestedRemote = self.Comm:CreateSignal("ClaimRequested")

	self.ClaimRequestedRemote:Connect(function(player, index)
		if not t.number(index) then return end

		local session = SessionsByPlayer[player]
		if not session then return end

		if not session:ClaimReward(index) then return end

		local reward = SessionRewardDefs[index].Reward

		RewardHelper.GiveReward(player, reward)

		if reward.Type == "Currency" then
			GuiEffectService.IndicatorRequestedRemote:Fire(player, {
				Text = `{RewardDisplayHelper.GetRewardText(reward)}`,
				Image = RewardDisplayHelper.GetRewardImage(reward),
				StartGui = `SessionRewardButton{index}`,
				EndGui = `GuiPanel{reward.CurrencyType}`,
			})
		end
	end)
end

return SessionRewardsService
