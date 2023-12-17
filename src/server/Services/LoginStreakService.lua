local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local LoginStreakRewardDefs = require(ReplicatedStorage.Shared.Defs.LoginStreakRewardDefs)
local Observers = require(ReplicatedStorage.Packages.Observers)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local RewardHelper = require(ServerScriptService.Server.Util.RewardHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)
local t = require(ReplicatedStorage.Packages.t)

local OneDay = 24 * 60 * 60
local TwoDays = OneDay * 2

local LoginStreakService = {
	Priority = 0,
}

type LoginStreakService = typeof(LoginStreakService)

function LoginStreakService.PrepareBlocking(self: LoginStreakService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "LoginStreakService")
	self.StatusRemote = self.Comm:CreateProperty("Status")

	self.Comm:CreateSignal("ClaimRequested"):Connect(function(player: Player, index)
		if not t.integer(index) then return end

		return DataService:GetSaveFile(player)
			:andThen(function(saveFile)
				local data = saveFile:Get("LoginStreakData")

				local indexIndex = Sift.Array.findWhere(data.AvailableRewardIndices, function(rewardIndex)
					local normalized = ((rewardIndex - 1) % #LoginStreakRewardDefs) + 1
					return normalized == index
				end)

				if indexIndex == nil then return false end

				saveFile:Update("LoginStreakData", function(oldData)
					return Sift.Dictionary.set(oldData, "AvailableRewardIndices", Sift.Array.removeIndex(oldData.AvailableRewardIndices, indexIndex))
				end)

				local reward = LoginStreakRewardDefs[index]
				RewardHelper.GiveReward(player, reward)

				if reward.Type == "Currency" then
					GuiEffectService.IndicatorRequestedRemote:Fire(player, {
						Text = `{RewardDisplayHelper.GetRewardText(reward)}`,
						Image = RewardDisplayHelper.GetRewardImage(reward),
						StartGui = `LoginStreakRewardButton{index}`,
						EndGui = `GuiPanel{reward.CurrencyType}`,
					})
				end

				return true
			end)
			:expect()
	end)

	Observers.observePlayer(function(player)
		local promise = DataService:GetSaveFile(player):andThen(function(saveFile)
			local now = Timestamp()
			local elapsed = now - saveFile:Get("LoginStreakData").Timestamp

			if elapsed < 0 then
				-- should only be possible in studio when testing
				saveFile:Update("LoginStreakData", function(oldData)
					return Sift.Dictionary.set(oldData, "Timestamp", now)
				end)
			end

			if elapsed > OneDay then
				saveFile:Update("LoginStreakData", function(oldData)
					return Sift.Dictionary.set(oldData, "Timestamp", now)
				end)

				if elapsed > TwoDays then
					saveFile:Update("LoginStreakData", function(oldData)
						return Sift.Dictionary.set(oldData, "Streak", 0)
					end)
				end

				saveFile:Update("LoginStreakData", function(oldData)
					local newStreak = oldData.Streak + 1

					return Sift.Dictionary.merge(oldData, {
						Streak = newStreak,
						AvailableRewardIndices = Sift.Array.append(oldData.AvailableRewardIndices, newStreak),
					})
				end)
			end
		end)

		local stopObserving = DataService:ObserveKey(player, "LoginStreakData", function(data)
			self.StatusRemote:SetFor(player, data)
		end)

		return function()
			promise:cancel()
			stopObserving()
		end
	end)
end

return LoginStreakService
