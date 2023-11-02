local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Configuration = require(ReplicatedStorage.Shared.Configuration)
local Lapis = require(ServerScriptService.ServerPackages.Lapis)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local SaveFile = require(ServerScriptService.Server.Classes.SaveFile)
local Sift = require(ReplicatedStorage.Packages.Sift)

local COLLECTION_NAME = "DataService" .. Configuration.DataStoreVersion

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
	self.Collection = Lapis.createCollection(COLLECTION_NAME, {
		lockExpireTime = 5.5 * 60,
		validate = function()
			return true
		end,
		defaultData = {
			Weapons = {
				Equipped = "WoodenBow",
				Owned = {
					WoodenBow = true,
				},
			},
			Currency = {
				Primary = 0,
				Secondary = 0,
				Premium = 0,
				Prestige = 0,
			},
		},
		migrations = {
			function(data)
				return Sift.Dictionary.merge(data, {
					Currency = {
						Normal = 0,
						Premium = 0,
					},
				})
			end,
			function(data)
				return Sift.Dictionary.removeKeys(
					Sift.Dictionary.set(data, "Currency", {
						Primary = data.Power,
						Secondary = data.Currency.Normal,
						Premium = data.Currency.Premium,
						Prestige = data.PrestigeCount,
					}),
					"Power",
					"PrestigeCount"
				)
			end,
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
