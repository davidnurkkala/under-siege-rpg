local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)

local PowerService = {
	Priority = 0,
}

type PowerService = typeof(PowerService)

function PowerService.PrepareBlocking(self: PowerService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "PowerService")
	self.PowerRemote = self.Comm:CreateProperty("Power", 0)
	self.PrestigeCountRemote = self.Comm:CreateProperty("PrestigeCount", 0)

	Observers.observePlayer(function(player)
		local promise = DataService:GetSaveFile(player):andThen(function(saveFile)
			saveFile:Observe("Power", function(level)
				self.PowerRemote:SetFor(player, level)
			end)

			saveFile:Observe("PrestigeCount", function(prestigeCount)
				self.PrestigeCountRemote:SetFor(player, prestigeCount)
			end)
		end)

		return function()
			promise:cancel()
		end
	end)
end

function PowerService.Start(_self: PowerService) end

function PowerService.AddPower(_self: PowerService, player: Player, amount: number)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		saveFile:Update("Power", function(oldPower)
			return oldPower + amount
		end)
	end)
end

return PowerService
