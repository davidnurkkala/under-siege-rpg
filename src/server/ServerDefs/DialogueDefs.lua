local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Dialogues = {
	TestDialogue = {
		Name = "Test Person",
		StartNodes = { "Root" },
		NodesOut = {
			Root = { Text = "Hello!", Nodes = { "GreetingFriendly", "GreetingAggressive" } },
			Friendly = { Text = "What can I tell you about this world?", Nodes = { "QuestionSky", "QuestionGrass" } },
			SkyIsBlue = { Text = "The sky is blue.", Nodes = { "Friendly" } },
			GrassIsGreen = { Text = "The grass is green.", Nodes = { "Friendly" } },
			Aggressive = { Text = "Well, I never! How rude. Go away!" },
		},
		NodesIn = {
			GreetingFriendly = { Text = "Hello, there!", Nodes = { "Friendly" } },
			GreetingAggressive = { Text = "Who the heck are you?", Nodes = { "Aggressive" } },
			QuestionSky = { Text = "What color is the sky?", Nodes = { "SkyIsBlue" } },
			QuestionGrass = { Text = "What color is the grass?", Nodes = { "GrassIsGreen" } },
		},
	},
}

return Sift.Dictionary.map(Dialogues, function(dialogue, id)
	assert(dialogue.Name, `Dialogue {id} has no name`)
	assert(dialogue.NodesOut, `Dialogue {id} has no output nodes`)
	assert(dialogue.NodesOut.Root, `Dialogue {id} has no output node with id "Root"`)
	assert(dialogue.NodesIn, `Dialogue {id} has no input nodes`)

	for nodeId in dialogue.NodesOut do
		assert(dialogue.NodesIn[nodeId] == nil, `Dialogue {id} has non-unique node id {nodeId} (this id is both an input and an output node)`)
	end

	for nodeId, node in Sift.Dictionary.merge(dialogue.NodesOut, dialogue.NodesIn) do
		assert(node.Text ~= nil, `Dialogue {id} node {nodeId} has no text`)

		if node.Nodes ~= nil then
			for _, connectedId in node.Nodes do
				local connectedNode = dialogue.NodesOut[connectedId] or dialogue.NodesIn[connectedId]
				assert(connectedNode ~= nil, `Dialogue {id} node {nodeId} connected to non-existent node {connectedId}`)
			end
		end
	end

	for nodeId, node in dialogue.NodesIn do
		if node.Nodes ~= nil then
			for _, connectedId in node.Nodes do
				assert(dialogue.NodesIn[connectedId] == nil, `Dialogue {id} node {nodeId} connected to input node {connectedId} (it must go to an output node)`)
			end
		end
	end

	local nodeIdSet = Sift.Array.toSet(Sift.Array.concat(Sift.Dictionary.keys(dialogue.NodesOut), Sift.Dictionary.keys(dialogue.NodesIn)))
	local function traverse(nodeId)
		if nodeId == false then return end
		if nodeIdSet[nodeId] == nil then return end

		nodeIdSet[nodeId] = nil

		local here = dialogue.NodesOut[nodeId] or dialogue.NodesIn[nodeId]
		if here.Nodes then
			for _, connectedId in here.Nodes do
				traverse(connectedId)
			end
		end
	end
	traverse("Root")
	assert(Sift.Set.count(nodeIdSet) == 0, `Dialogue {id} nodes {table.concat(Sift.Set.toArray(nodeIdSet), ", ")} are orphaned`)

	return Sift.Dictionary.merge(dialogue, {
		Id = id,
	})
end)
