local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)

local OneDay = 24 * 60 * 60
local TwoDays = OneDay * 2

local LoginStreakService = {
	Priority = 0,
}

type LoginStreakService = typeof(LoginStreakService)

function LoginStreakService.PrepareBlocking(self: LoginStreakService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "LoginStreakService")

	Observers.observePlayer(function(player)
		local promise = DataService:GetSaveFile(player):andThen(function(saveFile)
			local now = Timestamp()
			local elapsed = now - saveFile:Get("LoginStreakData").Timestamp

			if elapsed < OneDay then return end

			saveFile:Update("LoginStreakData", function(oldData)
				return Sift.Dictionary.set(oldData, "Timestamp", now)
			end)

			if elapsed > TwoDays then saveFile:Update("LoginStreakData", function(oldData)
				return Sift.Dictionary.set(oldData, "Streak", 0)
			end) end

			saveFile:Update("LoginStreakData", function(oldData)
				return Sift.Dictionary.set(oldData, "Streak", oldData.Streak + 1)
			end)
		end)

		return function()
			promise:cancel()
		end
	end)
end

return LoginStreakService
