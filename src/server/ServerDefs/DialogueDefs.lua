local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Dialogues = {
	TestDialogue = {
		Name = "Test Person",
		StartNodes = { "Root" },
		NodesOut = {
			Root = { Text = "Hello!", Nodes = { "GreetingFriendly", "GreetingAggressive" } },
			Friendly = { Text = "What can I tell you about this world?", Nodes = { "QuestionSky", "QuestionGrass", "QuestionIndustrial" } },
			SkyIsBlue = { Text = "The sky is blue.", Nodes = { "Friendly" } },
			GrassIsGreen = { Text = "The grass is green.", Nodes = { "Friendly" } },
			Aggressive = {
				Text = "Well, I never! How rude. Go away!",
				Callback = function(self)
					Promise.fromEvent(self.Destroyed):andThen(function()
						local char = self.Player.Character
						char.Humanoid.Sit = true

						local velocity = Random.new():NextUnitVector() * 1e3
						velocity = Vector3.new(velocity.X, math.abs(velocity.Y), velocity.Z)

						local mover = Instance.new("BodyVelocity")
						mover.MaxForce = Vector3.one * 1e9
						mover.Velocity = velocity
						mover.Parent = char.PrimaryPart
						task.delay(0.25, mover.Destroy, mover)
					end)
				end,
			},
			IndustrialRevolution = {
				Text = "The Industrial Revolution and its consequences have been a disaster for the human race. They have greatly increased the life-expectancy of those of us who live in “advanced” countries, but they have destabilized society, have made life unfulfilling, have subjected human beings to indignities, have led to widespread psychological suffering (in the Third World to physical suffering as well) and have inflicted severe damage on the natural world.",
				Nodes = { "Friendly" },
			},
		},
		NodesIn = {
			GreetingFriendly = { Text = "Hello, there!", Nodes = { "Friendly" } },
			GreetingAggressive = { Text = "Who the heck are you?", Nodes = { "Aggressive" } },
			QuestionSky = { Text = "What color is the sky?", Nodes = { "SkyIsBlue" } },
			QuestionGrass = {
				Text = "What color is the grass?",
				Nodes = { "GrassIsGreen" },
			},
			QuestionIndustrial = { Text = "What can you tell me about the industrial revolution and its consequences?", Nodes = { "IndustrialRevolution" } },
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

	for nodeId, node in dialogue.NodesOut do
		if node.Nodes then
			local hasOutputs = false
			local hasInputs = false
			for _, otherNodeId in node.Nodes do
				if dialogue.NodesIn[otherNodeId] then
					hasInputs = true
					if hasOutputs then break end
				elseif dialogue.NodesOut[otherNodeId] then
					hasOutputs = true
					if hasInputs then break end
				end
			end
			if hasOutputs and hasInputs then
				error(
					`Dialogue {id} has output node {nodeId} which is connected to both input and output nodes (it must only be connected to one or the other)`
				)
			end
		end
	end

	return Sift.Dictionary.merge(dialogue, {
		Id = id,
	})
end)
