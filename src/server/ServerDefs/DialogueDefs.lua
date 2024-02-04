local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battle = require(ServerScriptService.Server.Classes.Battle)
local BattleHelper = require(ServerScriptService.Server.Util.BattleHelper)
local CutsceneService = require(ServerScriptService.Server.Services.CutsceneService)
local GenericShopService = require(ServerScriptService.Server.Services.GenericShopService)
local LobbySession = require(ServerScriptService.Server.Classes.LobbySession)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Promise = require(ReplicatedStorage.Packages.Promise)
local ServerFade = require(ServerScriptService.Server.Util.ServerFade)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WorldService = require(ServerScriptService.Server.Services.WorldService)

local Dialogues = {
	OpeningCutscene = {
		Name = "",
		StartNodes = { "Line1" },
		NodesOut = {
			Line1 = {
				Text = "The kingdom has fallen before the might of the orcish armies.",
				Args = {
					TextSpeed = 0.1,
				},
				Nodes = { "Line2" },
				Callback = function(self)
					CutsceneService:Begin(self.Player)
				end,
			},
			Line2 = {
				Text = "You must make your last stand. The final battle is now.",
				Args = {
					TextSpeed = 0.1,
				},
				Callback = function(self)
					CutsceneService:Step(self.Player)
				end,
				PostCallback = function(self)
					CutsceneService:OnFinish(self.Player):andThen(function()
						ServerFade(self.Player, nil, function()
							CutsceneService:Step(self.Player)

							local session = LobbySessions.Get(self.Player)
							session:Destroy()

							return Promise.delay(0.5):andThenCall(Battle.fromPlayerVersusBattler, self.Player, "OpeningCutsceneOrcishGeneral", {
								Deck = {
									Pikeman = 5,
									Crossbowman = 5,
									Footman = 5,
									RoyalGuard = 3,
									RoyalRanger = 3,
									RoyalCavalry = 3,
									MasterMage = 3,
								},
								BaseId = "OldCastle",
							})
						end):andThen(function(battle)
							return Promise.fromEvent(battle.Finished):andThenReturn(battle)
						end):andThen(function(battle)
							return ServerFade(self.Player, {
								DisplayOrder = 256,
							}, function()
								self:SetNodeById("Line3")
								battle:Destroy()
								WorldService:TeleportToWorldRaw(self.Player, "World1")
								return Promise.fromEvent(self.Destroyed):andThenCall(LobbySession.promised, self.Player)
							end)
						end)
					end)

					CutsceneService:Step(self.Player)

					return true
				end,
			},
			Line3 = {
				Text = "You flee your castle in disgrace. Your army is shattered. Some loyal peasants join you in exile, swearing to fight for you.",
				Args = {
					TextSpeed = 0.5,
				},
				Nodes = { "Line4" },
			},
			Line4 = {
				Text = "You must rebuild your strength and retake your castle.",
				Args = {
					TextSpeed = 0.5,
				},
				Nodes = { "Line5" },
			},
			Line5 = {
				Text = "This is your destiny.",
				Args = {
					TextSpeed = 0.1,
				},
			},
		},
		NodesIn = {},
	},
	TestDialogue = {
		Name = "Test Person",
		StartNodes = { "Root" },
		NodesOut = {
			Root = { Text = "Hello!", Nodes = { "GreetingFriendly", "GreetingAggressive", "Shop" } },
			Friendly = { Text = "What can I tell you about this world?", Nodes = { "QuestionSky", "QuestionGrass", "QuestionIndustrial" } },
			SkyIsBlue = { Text = "The sky is blue.", Nodes = { "Friendly" } },
			GrassIsGreen = { Text = "The grass is green.", Nodes = { "Friendly" } },
			Aggressive = {
				Text = "Well, I never! How rude. Go away!",
				Animation = "TalkingCalm",
			},
			IndustrialRevolution = {
				Text = "The Industrial Revolution and its consequences have been a disaster for the human race. They have greatly increased the life-expectancy of those of us who live in “advanced” countries, but they have destabilized society, have made life unfulfilling, have subjected human beings to indignities, have led to widespread psychological suffering (in the Third World to physical suffering as well) and have inflicted severe damage on the natural world.",
				Nodes = { "Friendly" },
			},
		},
		NodesIn = {
			Shop = {
				Text = "Can I see your wares?",
				Callback = function(self)
					GenericShopService:OpenShop(self.Player, "World1Mage")
				end,
			},
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
	PeasantJohnSower = {
		Name = "John Sower, Peasant",
		StartNodes = { "Root" },
		NodesOut = {
			Root = { Text = "Hey, lord. Me and the boys are always up for a good fight. Want to have a go?", Nodes = { "Challenge" } },
			Defeated = { Text = "Good fight, lord! You're as good as they say. We'll get the best of you next time, I'm sure." },
			Victorious = {
				Text = "Good fight, lord! Far be it from some humble farmers such as us to be proud. You're sure to beat us next time, want to try us again?",
				Nodes = { "Challenge" },
			},
		},
		NodesIn = {
			Challenge = {
				Text = "Sure, let's fight.",
				Callback = function(self)
					BattleHelper.FadeToBattle(self.Player, "Peasant"):andThen(function(playerWon)
						if playerWon then
							self:SetNodeById("Defeated")
						else
							self:SetNodeById("Victorious")
						end
					end)

					return true
				end,
			},
		},
	},
}

return Sift.Dictionary.map(Dialogues, function(dialogue, id)
	assert(dialogue.Name, `Dialogue {id} has no name`)
	assert(dialogue.NodesOut, `Dialogue {id} has no output nodes`)
	assert(dialogue.NodesIn, `Dialogue {id} has no input nodes`)
	assert(dialogue.StartNodes, `Dialogue {id} has no start nodes`)

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
	-- assert(Sift.Set.count(nodeIdSet) == 0, `Dialogue {id} nodes {table.concat(Sift.Set.toArray(nodeIdSet), ", ")} are orphaned`)

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
