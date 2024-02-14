local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Default = require(ReplicatedStorage.Shared.Util.Default)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local QuestController = require(ReplicatedStorage.Shared.Controllers.QuestController)
local RatioText = require(ReplicatedStorage.Shared.React.Common.RatioText)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local UseProperty = require(ReplicatedStorage.Shared.React.Hooks.UseProperty)

local function questTracker(props: {
	Quest: any,
})
	local inBattle = UseProperty(BattleController.InBattle)

	if inBattle then return end
	if not props.Quest then return end

	return React.createElement(Container, {
		Size = UDim2.fromScale(0.2, 1),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
	}, {
		Layout = React.createElement(ListLayout, {
			Padding = UDim.new(0, 4),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),

		Title = React.createElement(RatioText, {
			LayoutOrder = 1,
			Ratio = 1 / 6,
			Text = TextStroke("Quest"),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		Description = React.createElement(RatioText, {
			LayoutOrder = 2,
			Ratio = 1 / 8,
			Text = if props.Quest == "Complete" then TextStroke("Quest complete!") else TextStroke(props.Quest.Description),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Bottom,
		}),
	})
end

return function()
	local menu = React.useContext(MenuContext)
	local quests, setQuests = React.useState({})
	local selectedQuestId, setSelectedQuestId = React.useState(nil)
	local trackedId, setTrackedId = React.useState(nil)

	local visible = menu.Is("Journal")
	local hasQuests = next(quests) ~= nil
	local selectedQuest = Default(quests[selectedQuestId], {
		Name = "",
		Summary = "",
		Description = "",
	})

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(QuestController:ObserveQuests(function(questsIn)
			if questsIn == nil then return end

			setQuests(Sift.Dictionary.filter(questsIn, function(quest)
				return quest ~= "Complete"
			end))
		end))

		trove:Add(QuestController:ObserveTrackedId(setTrackedId))

		return function()
			trove:Clean()
		end
	end, {})

	React.useEffect(function()
		if not visible then setSelectedQuestId(nil) end
	end, { visible })

	return React.createElement(React.Fragment, nil, {
		QuestTracker = React.createElement(questTracker, {
			Quest = quests[trackedId],
		}),

		QuestMenu = React.createElement(SystemWindow, {
			Visible = visible,
			HeaderText = TextStroke("Quests"),
			[React.Event.Activated] = function()
				menu.Unset("Journal")
			end,
		}, {
			NoQuests = React.createElement(Label, {
				Visible = not hasQuests,
				Text = TextStroke("You don't have any active quests."),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 0.2),
			}),

			QuestDetails = React.createElement(Container, {
				Visible = (selectedQuestId ~= nil),
			}, {
				Details = React.createElement(Container, {
					Size = UDim2.fromScale(1, 0.8),
				}, {
					Layout = React.createElement(ListLayout, {
						Padding = UDim.new(0, 6),
					}),
					Name = React.createElement(RatioText, {
						LayoutOrder = 1,
						Ratio = 1 / 18,
						Size = UDim2.fromScale(1, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = TextStroke(selectedQuest.Name),
					}),
					Summary = React.createElement(RatioText, {
						LayoutOrder = 2,
						Ratio = 1 / 26,
						Size = UDim2.fromScale(1, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = TextStroke(selectedQuest.Summary),
					}),
					CurrentStage = React.createElement(RatioText, {
						LayoutOrder = 3,
						Ratio = 1 / 22,
						Size = UDim2.fromScale(1, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = TextStroke(`Current objective:\n{selectedQuest.Description}`),
					}),
				}),

				Buttons = React.createElement(Container, {
					Size = UDim2.fromScale(1, 0.2),
					Position = UDim2.fromScale(0, 1),
					AnchorPoint = Vector2.new(0, 1),
				}, {
					Layout = React.createElement(ListLayout, {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 10),
					}),

					Back = React.createElement(Button, {
						LayoutOrder = 2,
						Size = UDim2.fromScale(2, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						[React.Event.Activated] = function()
							setSelectedQuestId(nil)
						end,
					}, {
						Label = React.createElement(Label, {
							Text = TextStroke("Back"),
						}),
					}),

					Track = React.createElement(Button, {
						LayoutOrder = 1,
						Size = UDim2.fromScale(2, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						ImageColor3 = if trackedId == selectedQuestId then ColorDefs.PaleRed else ColorDefs.LightBlue,
						[React.Event.Activated] = function()
							if trackedId == selectedQuestId then
								QuestController.TrackId(nil)
							else
								QuestController.TrackId(selectedQuestId)
							end
						end,
					}, {
						Label = React.createElement(Label, {
							Text = TextStroke(if trackedId == selectedQuestId then "Untrack" else "Track"),
						}),
					}),
				}),
			}),

			Quests = React.createElement(ScrollingFrame, {
				Visible = hasQuests and (selectedQuestId == nil),
				RenderLayout = function(setCanvasSize)
					return React.createElement(ListLayout, {
						[React.Change.AbsoluteContentSize] = function(object)
							setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
						end,
					})
				end,
			}, {
				Panels = React.createElement(
					React.Fragment,
					nil,
					Sift.Array.map(
						Sift.Array.sort(Sift.Dictionary.keys(quests), function(idA, idB)
							local a, b = quests[idA], quests[idB]
							print(idA, a)
							print(idB, b)
							return a.Name < b.Name
						end),
						function(id, index)
							local quest = quests[id]

							return React.createElement(LayoutContainer, {
								Size = UDim2.fromScale(1, 0.15),
								SizeConstraint = Enum.SizeConstraint.RelativeXX,
								Padding = 6,
								LayoutOrder = index,
							}, {
								Panel = React.createElement(Panel, {
									ImageColor3 = if trackedId == id then ColorDefs.PalePurple else ColorDefs.Gray50,
								}, {
									Name = React.createElement(Label, {
										TextXAlignment = Enum.TextXAlignment.Left,
										Size = UDim2.fromScale(0.7, 0.65),
										AnchorPoint = Vector2.new(0, 0.5),
										Position = UDim2.fromScale(0, 0.5),
										Text = TextStroke(quest.Name),
									}),
									Select = React.createElement(LayoutContainer, {
										Padding = 8,
										Size = UDim2.fromScale(0.2, 1),
										Position = UDim2.fromScale(0.8, 0),
									}, {
										Button = React.createElement(Button, {
											ImageColor3 = ColorDefs.LightPurple,
											[React.Event.Activated] = function()
												setSelectedQuestId(id)
											end,
										}, {
											Label = React.createElement(Label, {
												Text = TextStroke("Select"),
											}),
										}),
									}),
								}),
							})
						end
					)
				),
			}),
		}),
	})
end
