local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local Invert = require(ReplicatedStorage.Shared.Util.Invert)
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

local QuestMapsByPlayer: { [Player]: { [string]: Badger.Condition } } = {}

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
			local map = {}

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
						map[id] = nil
						Badger.stop(completed)
						saveFile:Update("QuestData", function(oldQuestData)
							questDescriptions:Update(function(oldDescriptions)
								return Sift.Dictionary.set(oldDescriptions, id, "Complete")
							end)
							return Sift.Dictionary.set(oldQuestData, id, "Complete")
						end)
						questDef.OnCompleted(player)
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

				map[id] = condition
			end

			QuestMapsByPlayer[player] = map
			trove:Add(function()
				QuestMapsByPlayer[player] = nil
			end)
		end)

		return function()
			trove:Clean()
		end
	end)
end

function QuestService.StartQuest(_self: QuestService, player: Player, questId: string)
	local map = QuestMapsByPlayer[player]
	if not map then return end

	local quest = map[questId]
	if not quest then return end

	if quest:getName() ~= "Unstarted" then return end

	EventStream.Event({ Kind = "QuestAdvanced", Player = player, QuestId = questId })
end

function QuestService.AdvanceQuest(_self: QuestService, player: Player, questId)
	local map = QuestMapsByPlayer[player]
	if not map then return end

	local quest = map[questId]
	if not quest then return end

	if quest:getName() == "Unstarted" then return end

	EventStream.Event({ Kind = "QuestAdvanced", Player = player, QuestId = questId })
end

function QuestService.GetQuestStage(_self: QuestService, player: Player, questId: string)
	return Promise.try(function()
		local map = QuestMapsByPlayer[player]
		if not map then return end

		local quest = map[questId]
		if not quest then return end

		return quest:getName()
	end)
end

function QuestService.IsQuestAtStage(_self: QuestService, player: Player, questId: string, stage: string)
	return Promise.try(function()
		local map = QuestMapsByPlayer[player]
		if not map then return false end

		local quest = map[questId]
		if not quest then return false end

		return quest:getName() == stage
	end)
end

function QuestService.IsQuestUnstarted(self: QuestService, player: Player, questId: string)
	return self:IsQuestComplete(player, questId):andThen(function(isComplete)
		if isComplete then return false end

		return self:IsQuestAtStage(player, questId, "Unstarted")
	end)
end

function QuestService.IsQuestInProgress(self: QuestService, player: Player, questId: string)
	return self:IsQuestComplete(player, questId):andThen(function(isComplete)
		if isComplete then return false end

		return self:IsQuestUnstarted(player, questId):andThen(Invert)
	end)
end

function QuestService.IsQuestComplete(_self: QuestService, player: Player, questId: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		print(saveFile:Get("QuestData"))
		return saveFile:Get("QuestData")[questId] == "Complete"
	end)
end

return QuestService
