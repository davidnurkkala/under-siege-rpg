local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Lapis = require(ServerScriptService.ServerPackages.Lapis)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local SaveFile = require(ServerScriptService.Server.Classes.SaveFile)

local DataService = {
	Priority = -1024,
}

type DataService = typeof(DataService)

local SaveFilesByPlayer: { [Player]: SaveFile.SaveFile } = {}
local LoadPromisesByPlayer: { [Player]: any } = {}

local function getDocumentKey(player: Player): string
	return tostring(player.UserId)
end

function DataService.PrepareBlocking(self: DataService)
	self.Collection = Lapis.createCollection("DataService", {
		validate = function()
			return true
		end,
		defaultData = {
			Level = 1,
			Experience = 0,
			PrestigeCount = 0,
		},
	})

	Observers.observePlayer(function(player: Player)
		self:GetSaveFile(player)

		return function()
			if LoadPromisesByPlayer[player] then
				LoadPromisesByPlayer[player]:cancel()
				LoadPromisesByPlayer[player] = nil
			end

			if SaveFilesByPlayer[player] then
				SaveFilesByPlayer[player]:Destroy()
				SaveFilesByPlayer[player] = nil
			end
		end
	end)
end

function DataService.GetSaveFile(self: DataService, player: Player)
	if SaveFilesByPlayer[player] then
		return Promise.resolve(SaveFilesByPlayer[player])
	else
		if not LoadPromisesByPlayer[player] then
			LoadPromisesByPlayer[player] = self.Collection:load(getDocumentKey(player)):andThen(function(document)
				local saveFile = SaveFile.new(document)
				SaveFilesByPlayer[player] = saveFile
				LoadPromisesByPlayer[player] = nil
				return saveFile
			end)
		end

		return LoadPromisesByPlayer[player]
	end
end

function DataService.Start(_self: DataService) end

return DataService
