local CollectionService = game:GetService("CollectionService")

local QuestHelper = {}

function QuestHelper.GetQuestTarget(questId: string, questTargetId: string)
	for _, object in CollectionService:GetTagged("QuestTarget") do
		if not object:IsDescendantOf(workspace) then continue end

		if object:GetAttribute("QuestTargetId") == questId .. questTargetId then return object end
	end
	return nil
end

return QuestHelper
