local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)

local QuestDefsById = Sift.Dictionary.map(ServerScriptService.Server.Quests:GetChildren(), function(source)
	local def = Sift.Dictionary.merge(require(source), {
		Id = source.Name,
	})

	return def, def.Id
end)

local QuestService = {
	Priority = 0,
}

type QuestService = typeof(QuestService)

function QuestService.PrepareBlocking(self: QuestService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "QuestService")
	self.QuestsRemote = self.Comm:CreateProperty("Quests", {})

	Observers.observePlayer(function(player)
		local trove = Trove.new()

		local questDescriptions = trove:Construct(Property, {}, Sift.Dictionary.equalsDeep)
		questDescriptions:Observe(function(descriptions)
			self.QuestsRemote:SetFor(player, descriptions)
		end)

		trove:AddPromise(DataService:GetSaveFile(player)):andThen(function(saveFile)
			local questData = saveFile:Get("QuestData")

			for id, questDef in QuestDefsById do
				if questData[id] == "Complete" then
					questDescriptions:Update(function(oldDescriptions)
						return Sift.Dictionary.set(oldDescriptions, id, "Complete")
					end)
					continue
				end

				local condition = Badger.start(Badger.onCompleted(
					Badger.onProcess(questDef.Condition(player), function(processed)
						questDescriptions:Update(function(oldDescriptions)
							return Sift.Dictionary.set(oldDescriptions, id, processed:getDescription())
						end)
						saveFile:Update("QuestData", function(oldQuestData)
							return Sift.Dictionary.set(oldQuestData, id, processed:save())
						end)
					end),
					function(completed)
						Badger.stop(completed)
						saveFile:Update("QuestData", function(oldQuestData)
							questDescriptions:Update(function(oldDescriptions)
								return Sift.Dictionary.set(oldDescriptions, id, "Complete")
							end)
							return Sift.Dictionary.set(oldQuestData, id, "Complete")
						end)
					end
				))

				if questData[id] then
					Promise.try(function()
						condition:load(questData[id])
					end):catch(function()
						print(`Something went wrong loading quest {id}, resetting`)
						condition:reset()
					end)
				end

				trove:Add(function()
					Badger.stop(condition)
				end)
			end
		end)

		return function()
			trove:Clean()
		end
	end)
end

function QuestService.IsQuestComplete(self: QuestService, player: Player, questId: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("QuestData")[questId] == "Complete"
	end)
end

return QuestService
