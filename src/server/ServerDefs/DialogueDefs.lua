local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battle = require(ServerScriptService.Server.Classes.Battle)
local BattleHelper = require(ServerScriptService.Server.Util.BattleHelper)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local CutsceneService = require(ServerScriptService.Server.Services.CutsceneService)
local DeckService = require(ServerScriptService.Server.Services.DeckService)
local DialogueHelper = require(ServerScriptService.Server.Util.DialogueHelper)
local GenericShopService = require(ServerScriptService.Server.Services.GenericShopService)
local GuideService = require(ServerScriptService.Server.Services.GuideService)
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
				Text = "Your kingdom has fallen before the might of the orcish armies.",
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
							local battler = battle.Battlers[1]
							GuideService:SetGuiGuide(self.Player, "GuiBattleAttackButton", {
								Offset = Vector2.new(50, -150),
								Anchor = Vector2.new(0.5, 0),
								Text = "Use this button to shoot!",
							})

							Promise.fromEvent(battler.Attacked):timeout(10):finally(function()
								GuideService:SetGuiGuide(self.Player, "GuiBattleAttackButton", nil)
							end)

							GuideService:SetGuiGuide(self.Player, "GuiBattleDeckButton1", {
								Offset = Vector2.new(200, -100),
								Anchor = Vector2.new(1, 0),
								Text = "Use these buttons to send soldiers!",
							})

							Promise.fromEvent(battle.CardPlayed, function(playingBattler)
								return playingBattler == battler
							end)
								:timeout(10)
								:finally(function()
									GuideService:SetGuiGuide(self.Player, "GuiBattleDeckButton1", nil)
								end)

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
				Text = "Defeated, you flee in disgrace. Your army is shattered. Some loyal peasants join you in exile, swearing to fight for you.",
				Args = {
					TextSpeed = 0.5,
				},
				Nodes = { "Line4" },
			},
			Line4 = {
				Text = "You must rebuild your strength, get vengeance on the orc general, and retake your kingdom.",
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
				PostCallback = function(self)
					GuideService:SetGuiGuide(self.Player, "GuiDeckButton", {
						Offset = Vector2.new(350, 0),
						Anchor = Vector2.new(1, 0.5),
						Text = "Use this button to view your army!",
					})

					Promise.fromEvent(GuideService.GuiActionDone, function(player, action, menuName)
						if player ~= self.Player then return false end
						if action ~= "MenuSet" then return false end

						return menuName == "Deck"
					end)
						:andThen(function()
							GuideService:SetGuiGuide(self.Player, "GuiDeckButton", nil)
							GuideService:SetGuiGuide(self.Player, "GuiDeckCardButtonPeasant", {
								Offset = Vector2.new(0, 100),
								Anchor = Vector2.new(0.5, 1),
								Text = "Use this button to examine your Peasant soldier!",
							})

							return Promise.fromEvent(GuideService.GuiActionDone, function(player, action, cardId)
								if player ~= self.Player then return false end
								if action ~= "DeckCardSelected" then return false end

								return cardId == "Peasant"
							end)
						end)
						:andThen(function()
							local upgradePrice = CardDefs.Peasant.Upgrades[1]

							return Promise.all(Sift.Array.map(Sift.Dictionary.keys(upgradePrice), function(currencyType)
								return CurrencyService:AddCurrency(self.Player, currencyType, upgradePrice[currencyType])
							end))
						end)
						:andThen(function()
							GuideService:SetGuiGuide(self.Player, "GuiDeckCardButtonPeasant", nil)
							GuideService:SetGuiGuide(self.Player, "GuiDeckCardDetailsUpgrade", {
								Offset = Vector2.new(-100, -200),
								Anchor = Vector2.new(0, 0),
								Text = "Use this button to upgrade your Peasant soldier!",
							})

							return Promise.fromEvent(DeckService.CardUpgraded, function(player, cardId)
								return player == self.Player and cardId == "Peasant"
							end)
						end)
						:andThen(function()
							GuideService:SetGuiGuide(self.Player, "GuiDeckCardDetailsUpgrade", nil)

							return Promise.fromEvent(GuideService.GuiActionDone, function(player, action, menuName)
								if player ~= self.Player then return false end
								if action ~= "MenuUnset" then return false end

								return menuName == "Deck"
							end)
						end)
						:andThen(function()
							DialogueHelper.StartDialogue(self.Player, "PostTutorial")
						end)
				end,
			},
		},
		NodesIn = {},
	},
	PostTutorial = {
		Name = "",
		StartNodes = { "Root" },
		NodesOut = {
			Root = {
				Text = "To defeat the orc general, you must become stronger. You must recruit soldiers, upgrade your army, and complete quests.",
				Nodes = { "Recruiting", "Gathering", "Questing" },
			},
			HowToRecruit = {
				Text = "To recruit new soldiers, you can:\n• Win battles against other commanders\n• Hire them at places like the mercenary guild\n• Complete quests",
				Args = { Alignment = Enum.TextXAlignment.Left },
				Nodes = { "Root" },
			},
			HowToGather = {
				Text = "To upgrade your army, you must acquire resources to use. To do this, you can:\n• Win battles against other commanders\n• Use services like the blacksmith to convert one resource into another\n• Gather them from the world, such as from ore rocks\n• Complete quests",
				Args = { Alignment = Enum.TextXAlignment.Left },
				Nodes = { "Root" },
			},
			HowToQuest = {
				Text = "To complete quests, you must find them first. Talk to NPCs and explore the world. Quests can give you new soldiers, abilities, resources, and more.",
				Nodes = { "Root" },
			},
		},
		NodesIn = {
			Recruiting = { Text = "How do I recruit new soldiers?", Nodes = { "HowToRecruit" } },
			Gathering = { Text = "How do I upgrade my army?", Nodes = { "HowToGather" } },
			Questing = { Text = "How do I complete quests?", Nodes = { "HowToQuest" } },
		},
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
