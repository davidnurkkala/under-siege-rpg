local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Configuration = require(ReplicatedStorage.Shared.Configuration)
local Lapis = require(ServerScriptService.ServerPackages.Lapis)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local SaveFile = require(ServerScriptService.Server.Classes.SaveFile)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)

local COLLECTION_NAME = "DataService" .. Configuration.DataStoreVersion

local DataService = {
	Priority = -1024,

	DefaultData = {
		Weapons = {
			Equipped = "WoodenBow",
			Owned = {
				WoodenBow = true,
			},
		},
		Cosmetics = {
			Bases = {
				Equipped = "Camp",
				Owned = {
					Camp = true,
				},
			},
		},
		Worlds = {
			World1 = true,
		},
		WorldCurrent = "World1",
		Currency = {
			Coins = 0,
			Gems = 10,
		},
		Boosts = {},
		Deck = {
			Equipped = {
				Peasant = true,
				Hunter = true,
				Militia = true,
			},
			Owned = {
				Peasant = 1,
				Hunter = 1,
				Militia = 1,
			},
		},
		Options = {
			AutoEquipCards = true,
		},
		LoginStreakData = {
			Timestamp = 0,
			Streak = 0,
			AvailableRewardIndices = {},
		},
		QuestData = {},
		IsFirstSession = true,
	},
}

type DataService = typeof(DataService)

local SaveFilesByPlayer: { [Player]: SaveFile.SaveFile } = {}
local LoadPromisesByPlayer: { [Player]: any } = {}
local FirstSessionsByPlayer: { [Player]: boolean } = {}

local function getDocumentKey(player: Player): string
	return tostring(player.UserId)
end

function DataService.PrepareBlocking(self: DataService)
	self.Collection = Lapis.createCollection(COLLECTION_NAME, {
		disableLockInStudio = true,
		lockExpireTime = 10 * 60,

		validate = function()
			return true
		end,

		defaultData = self.DefaultData,

		migrations = {
			function(oldData)
				return Sift.Dictionary.set(oldData, "Cosmetics", self.DefaultData.Cosmetics)
			end,
			function(oldData)
				return Sift.Dictionary.removeKey(oldData, "ResourceNodeStates")
			end,
			function(oldData)
				return Sift.Dictionary.set(oldData, "Cosmetics", self.DefaultData.Cosmetics)
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

			if SaveFilesByPlayer[player] then SaveFilesByPlayer[player]:Destroy():andThen(function()
				SaveFilesByPlayer[player] = nil
			end) end

			FirstSessionsByPlayer[player] = nil
		end
	end)
end

function DataService.GetSaveFile(self: DataService, player: Player)
	if SaveFilesByPlayer[player] then
		return Promise.resolve(SaveFilesByPlayer[player])
	else
		if not LoadPromisesByPlayer[player] then
			LoadPromisesByPlayer[player] = self.Collection
				:load(getDocumentKey(player))
				:andThen(function(document)
					local saveFile = SaveFile.new(document)

					if saveFile:Get("IsFirstSession") then
						saveFile:Set("IsFirstSession", nil)
						FirstSessionsByPlayer[player] = true
					end

					SaveFilesByPlayer[player] = saveFile
					LoadPromisesByPlayer[player] = nil

					return saveFile
				end)
				:catch(function()
					player:Kick("There was a problem retrieving your data. Your data is safe. Please try again in 10 minutes.")

					return Promise.reject("Save file could not be retrieved.")
				end)
		end

		return LoadPromisesByPlayer[player]
	end
end

function DataService.IsFirstSession(_self: DataService, player: Player)
	if LoadPromisesByPlayer[player] then
		return LoadPromisesByPlayer[player]:andThenReturn(FirstSessionsByPlayer[player])
	else
		return Promise.resolve(FirstSessionsByPlayer[player])
	end
end

function DataService.ObserveKey(self: DataService, player: Player, key: string, callback)
	local trove = Trove.new()

	trove:AddPromise(self:GetSaveFile(player)
		:andThen(function(saveFile)
			trove:Add(saveFile:Observe(key, callback))
		end)
		:catch(function() end))

	return function()
		trove:Clean()
	end
end

return DataService
