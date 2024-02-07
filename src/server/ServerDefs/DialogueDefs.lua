local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battle = require(ServerScriptService.Server.Classes.Battle)
local BattleHelper = require(ServerScriptService.Server.Util.BattleHelper)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local ConsequenceHelper = require(ServerScriptService.Server.Util.ConsequenceHelper)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local CutsceneService = require(ServerScriptService.Server.Services.CutsceneService)
local DeckService = require(ServerScriptService.Server.Services.DeckService)
local DialogueHelper = require(ServerScriptService.Server.Util.DialogueHelper)
local GenericShopService = require(ServerScriptService.Server.Services.GenericShopService)
local GuideService = require(ServerScriptService.Server.Services.GuideService)
local LobbySession = require(ServerScriptService.Server.Classes.LobbySession)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local MusicService = require(ServerScriptService.Server.Services.MusicService)
local Promise = require(ReplicatedStorage.Packages.Promise)
local QuestService = require(ServerScriptService.Server.Services.QuestService)
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
					MusicService:SetSoundtrack(self.Player, { "TheKingdomIsFallen" })
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
	PeasantJohnSower = {
		Name = "John Sower, Peasant",
		StartNodes = { "Unmet", "Root" },
		NodesOut = {
			Unmet = {
				Text = "Hello, milord. Heard about you losing your kingdom to the orcs. Tough streak of luck that is.",
				Conditions = {
					function(self)
						return self:QuickFlagIsDown("HasMet")
					end,
				},
				Callback = function(self)
					self:QuickFlagRaise("HasMet")
				end,
				Nodes = { "UnmetFight" },
			},
			UnmetFight = {
				Text = "If you're looking to train your army, me and the boys are always up for a good fight. Want to have a go?",
				Nodes = { "Challenge" },
			},
			Root = { Text = "Hey, milord. Me and the boys are always up for a good fight. Want to have a go?", Nodes = { "Challenge" } },
			Defeated = { Text = "Good fight, milord! You're as good as they say. We'll get the best of you next time, I'm sure." },
			Victorious = {
				Text = "Good fight, milord! Far be it from some humble farmers such as us to be proud. You're sure to beat us next time, want to try us again?",
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
	MasterMageAtraeus = {
		Name = "Atraeus, Master Mage",
		StartNodes = { "Unmet", "Met" },
		NodesOut = {
			Unmet = {
				Text = "Greetings, young lord. I know you seek power in order to retake your kingdom from your enemies. I can offer you that power... for a price.",
				Conditions = {
					function(self)
						return self:QuickFlagIsDown("HasMet")
					end,
				},
				Callback = function(self)
					self:QuickFlagRaise("HasMet")
				end,
				Nodes = { "Shop" },
			},
			Met = {
				Text = "Greetings, young lord. Do you wish again to peruse the mystical?",
				Nodes = { "Shop" },
			},
		},
		NodesIn = {
			Shop = {
				Text = "Let me see what spells you have.",
				Callback = function(self)
					GenericShopService:OpenShop(self.Player, "World1Mage")
				end,
			},
		},
	},
	GuildmasterKutz = {
		Name = "Kutz, Guildmaster",
		StartNodes = { "Unmet", "Met" },
		NodesOut = {
			Unmet = {
				Text = "Hmph! Well, if it isn't the lordling that's lost his kingdom. What a sorry excuse of a warrior, you are.",
				Conditions = {
					function(self)
						return self:QuickFlagIsDown("HasMet")
					end,
				},
				Callback = function(self)
					self:QuickFlagRaise("HasMet")
				end,
				Nodes = { "Unmet2" },
			},
			Unmet2 = {
				Text = "Lucky for weaklings like you, skill can be bought. I've got men ready to fight if you've got the coin. What'll it be?",
				Nodes = { "Shop" },
			},
			Met = {
				Text = "Welcome back, lordling. Looking for some more muscle?",
				Nodes = { "Shop" },
			},
		},
		NodesIn = {
			Shop = {
				Text = "Let me see what soldiers are for hire.",
				Callback = function(self)
					GenericShopService:OpenShop(self.Player, "World1Guildmaster")
				end,
			},
		},
	},
	MerchantJim = {
		Name = "Jim, Merchant",
		StartNodes = { "DeliveryQuestInProgress", "Unmet", "Met" },
		NodesOut = {
			DeliveryQuestInProgress = {
				Text = "Hello, milord! How's finding my shipment coming along?",
				Nodes = { "DeliveryQuestWorkingOnIt", "DeliveryQuestDone", "Shop" },
				Conditions = {
					function(self)
						return self:SharedGet("JimDeliveryQuest"):andThen(function(value)
							return value ~= nil and value ~= "Complete"
						end)
					end,
				},
			},
			Unmet = {
				Text = "Ah! A new face in town. My name's Jim! I run a little shop here. I try to stock a bit of everything. Care to see what I've got?",
				Conditions = {
					function(self)
						return self:QuickFlagIsDown("HasMet")
					end,
				},
				Callback = function(self)
					self:QuickFlagRaise("HasMet")
				end,
				Nodes = { "Shop" },
			},
			Met = {
				Text = "Welcome back to Jim's! What are you looking for?",
				Nodes = { "Shop", "Help" },
			},
			DeliveryQuestStart1 = {
				Text = "As a matter of fact, I've been expecting a delivery from a town up in the mountains for weeks, now.",
				Nodes = { "DeliveryQuestStart2" },
			},
			DeliveryQuestStart2 = {
				Text = "I've heard there are bandits along the road, which is maybe why the shipment's being held up.",
				Nodes = { "DeliveryQuestStart3" },
			},
			DeliveryQuestStart3 = {
				Text = "Would you travel up into the mountain village and speak to Holden? I'll pay you well for my shipment.",
				Nodes = { "DeliveryQuestYes", "DeliveryQuestNo" },
			},
			DeliveryQuestGlad = {
				Text = "Wonderful! Best of luck, and be safe on the roads. These are dangerous times!",
			},
			DeliveryQuestSad = {
				Text = "Ah, well, I understand. Just let me know if you change your mind!",
				Nodes = { "Shop" },
			},
			DeliveryQuestComplete = {
				Text = "Amazing! You've done wonderful work. Please, accept this reward with my thanks. [Jim pays you 6000 coins.]",
				Callback = function(self)
					self:SharedSet("JimDeliveryQuest", "Complete"):andThen(function()
						CurrencyService:AddCurrency(self.Player, "Coins", 6000)
					end)
				end,
				Nodes = { "Shop" },
			},
		},
		NodesIn = {
			Shop = {
				Text = "Let me see your wares.",
				Callback = function(self)
					GenericShopService:OpenShop(self.Player, "World1Merchant")
				end,
			},
			Help = {
				Text = "Got any work?",
				Conditions = {
					function(self)
						return self:SharedGet("JimDeliveryQuest"):andThen(function(value)
							return value == nil
						end)
					end,
				},
				Nodes = { "DeliveryQuestStart1" },
			},
			DeliveryQuestYes = {
				Text = "Yes, I'll get your shipment.",
				Nodes = { "DeliveryQuestGlad" },
				Callback = function(self)
					self:SharedSet("JimDeliveryQuest", "TalkToHolden")
				end,
			},
			DeliveryQuestNo = {
				Text = "No, I can't do that.",
				Nodes = { "DeliveryQuestSad" },
			},
			DeliveryQuestWorkingOnIt = {
				Text = "I'm still working on it.",
				Nodes = { "DeliveryQuestGlad" },
				Conditions = {
					function(self)
						return self:SharedGet("JimDeliveryQuest"):andThen(function(value)
							return value ~= "ReturnToJim"
						end)
					end,
				},
			},
			DeliveryQuestDone = {
				Text = "I have your shipment right here.",
				Nodes = { "DeliveryQuestComplete" },
				Conditions = {
					function(self)
						return self:SharedGet("JimDeliveryQuest"):andThen(function(value)
							return value == "ReturnToJim"
						end)
					end,
				},
			},
		},
	},
	HoldenVillager = {
		Name = "Holden",
		StartNodes = { "Start" },
		NodesOut = {
			Start = {
				Text = "Greetings, milord. Welcome to the village of Bilmen.",
				Nodes = { "DeliveryQuestGetShipment" },
			},
			DeliveryQuestILostIt = {
				Text = "Ah, milord, my deepest apologies, but the shipment was stolen from me by bandits on the road. I hardly escaped with my life!",
				Nodes = { "DeliveryQuestILostIt2" },
			},
			DeliveryQuestILostIt2 = {
				Text = "It was a bandit by the name of Royce. Perhaps you can find him and retrieve the shipment. I can help you no more, I'm afraid.",
				Callback = function(self)
					self:SharedSet("JimDeliveryQuest", "GetFromRoyce")
				end,
			},
		},
		NodesIn = {
			DeliveryQuestGetShipment = {
				Text = "I'm here looking for Jim's shipment.",
				Nodes = { "DeliveryQuestILostIt" },
				Conditions = {
					function(self)
						return self:SharedGet("JimDeliveryQuest"):andThen(function(value)
							return value == "TalkToHolden"
						end)
					end,
				},
			},
		},
	},
	RoyceBandit = {
		Name = "Royce",
		StartNodes = { "Start" },
		NodesOut = {
			Start = {
				Text = "You'll walk away if you know what's good for you.",
				Nodes = { "DeliveryQuestFight", "Fight" },
			},
			DeliveryQuestDefeated = {
				Text = "I yield, I yield! Take whatever you want, just don't kill me!",
				Callback = function(self)
					self:SharedSet("JimDeliveryQuest", "ReturnToJim")
				end,
			},
			DeliveryQuestFightMe = {
				Text = "You want <b>MY</b> loot? You're not leaving here alive, fool!",
				PostCallback = function(self)
					BattleHelper.FadeToBattle(self.Player, "RoyceBandit"):andThen(function(playerWon)
						if playerWon then
							self:SetNodeById("DeliveryQuestDefeated")
						else
							self:Destroy()
							ConsequenceHelper.Mugged(self.Player, 0.1, function(amount)
								return `Royce's gang forced you to retreat, stealing {amount} coins from you.`
							end)
						end
					end)

					return true
				end,
			},
		},
		NodesIn = {
			DeliveryQuestFight = {
				Text = "I've come to claim the shipment you stole from Holden.",
				Conditions = {
					function(self)
						return self:SharedGet("JimDeliveryQuest"):andThen(function(value)
							return value == "GetFromRoyce"
						end)
					end,
				},
				Nodes = { "DeliveryQuestFightMe" },
			},
			Fight = {
				Text = "Fight me, bandit!",
				Conditions = {
					function(self)
						return self:SharedGet("JimDeliveryQuest"):andThen(function(value)
							return value ~= "GetFromRoyce"
						end)
					end,
				},
				Callback = function(self)
					BattleHelper.FadeToBattle(self.Player, "RoyceBandit"):andThen(function(playerWon)
						if not playerWon then
							ConsequenceHelper.Mugged(self.Player, 0.1, function(amount)
								return `Royce's gang forced you to retreat, stealing {amount} coins from you.`
							end)
						end
					end)
				end,
			},
		},
	},
	KennyBlacksmith = {
		Name = "Kenny Smivvet",
		StartNodes = { "Unmet", "Met" },
		NodesOut = {
			Unmet = {
				Text = "Oi, milord! Watch the forge. It's hotter than it looks! You need metal smelted and shaped, I'm your man. What can I do for ya?",
				Conditions = {
					function(self)
						return self:QuickFlagIsDown("HasMet")
					end,
				},
				Callback = function(self)
					self:QuickFlagRaise("HasMet")
				end,
				Nodes = { "Shop" },
			},
			Met = {
				Text = "Hey again, milord. Need something forged?",
				Nodes = { "Shop" },
			},
		},
		NodesIn = {
			Shop = {
				Text = "Let me see what you can do.",
				Callback = function(self)
					GenericShopService:OpenShop(self.Player, "World1Blacksmith")
				end,
			},
		},
	},
	LyndonNoble = {
		Name = "Lyndon Elwyne, Count of Karyston",
		StartNodes = { "Unmet", "Met" },
		NodesOut = {
			Unmet = {
				Text = "Hm? Ah, if it isn't the refugee noble newly unlanded due to the orcs. A pity. What do you want?",
				Nodes = { "MineAccess" },
				Conditions = {
					function(self)
						return self:QuickFlagIsDown("HasMet")
					end,
				},
				Callback = function(self)
					self:QuickFlagRaise("HasMet")
				end,
			},
			Met = {
				Text = "What do you want?",
				Nodes = { "MineAccess", "Spar" },
			},
			FightMeForIt = {
				Text = "[He cocks an eyebrow.] You want access to <i>my</i> mine? Very well, but you'll have to earn it.",
				Nodes = { "FightMeForIt2" },
			},
			FightMeForIt2 = {
				Text = "A true noble knows how to let his lessers do his work for him.",
				Nodes = { "FightMeForIt3" },
			},
			FightMeForIt3 = {
				Text = "Defeat me without personally attacking -- let it all be done by your soldiers. Are we agreed?",
				Nodes = { "AcceptFight" },
			},
			Victorious = {
				Text = "Ah, well, it seems that I am the better commander. Perhaps <i>I</i> would not have lost my castle to the orcs, hm?",
			},
			Defeated = {
				Text = "Ah, well fought, my lord. You have earned my respect. You may enter my mine whenever you please.",
			},
			DefeatedWrong = {
				Text = "Ah, well fought, my lord, but you have failed my condition. You were not to attack. My mine remains closed to you.",
			},
		},
		NodesIn = {
			MineAccess = {
				Text = "Can I have access to your mine?",
				Nodes = { "FightMeForIt" },
				Conditions = {
					function(self)
						return QuestService:IsQuestComplete(self.Player, "DefeatNoble"):andThen(function(isComplete)
							return not isComplete
						end)
					end,
				},
			},
			Spar = {
				Text = "I'd like to fight.",
				Conditions = {
					function(self)
						return QuestService:IsQuestComplete(self.Player, "DefeatNoble"):andThen(function(isComplete)
							return isComplete
						end)
					end,
				},
				Callback = function(self)
					BattleHelper.FadeToBattle(self.Player, "Noble")
				end,
			},
			AcceptFight = {
				Text = "Okay, let's fight.",
				Callback = function(self)
					BattleHelper.FadeToBattle(self.Player, "Noble"):andThen(function(playerWon)
						if playerWon then
							QuestService:IsQuestComplete(self.Player, "DefeatNoble"):andThen(function(isComplete)
								if isComplete then
									self:SetNodeById("Defeated")
								else
									self:SetNodeById("DefeatedWrong")
								end
							end)
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
