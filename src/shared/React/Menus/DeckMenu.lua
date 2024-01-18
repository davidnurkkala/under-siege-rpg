local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CardContents = require(ReplicatedStorage.Shared.React.Cards.CardContents)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Configuration = require(ReplicatedStorage.Shared.Configuration)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local DeckController = require(ReplicatedStorage.Shared.Controllers.DeckController)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local RatioText = require(ReplicatedStorage.Shared.React.Common.RatioText)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

function cardDetails(props: {
	DeckIsFull: boolean,
	CardId: string,
	Level: number,
	Equipped: boolean,
	Close: () -> (),
	Toggle: () -> (),
})
	return React.createElement(React.Fragment, nil, {
		Card = React.createElement(Panel, {
			Size = UDim2.fromScale(0.3, 1),
			ImageColor3 = ColorDefs.PaleGreen,
		}, {
			Ratio = React.createElement(Aspect, {
				AspectRatio = 2.5 / 3.5,
			}),

			Contents = React.createElement(CardContents, {
				CardId = props.CardId,
				Level = props.Level,
			}),
		}),

		Description = React.createElement(Container, {
			Size = UDim2.fromScale(0.7, 0.9),
			Position = UDim2.fromScale(0.3, 0),
		}, {
			Padding = React.createElement(PaddingAll, {
				Padding = UDim.new(0.05, 0),
			}),

			ScrollingFrame = React.createElement(ScrollingFrame, {
				ScrollBarThickness = 8,
				ScrollBarImageColor3 = ColorDefs.Blue,
				RenderLayout = function(setCanvasSize)
					return React.createElement(ListLayout, {
						[React.Change.AbsoluteContentSize] = function(object)
							setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y + 4))
						end,
					})
				end,
			}, {
				Padding = React.createElement("UIPadding", {
					PaddingRight = UDim.new(0, 12),
				}),

				Text = React.createElement(RatioText, {
					Ratio = 1 / 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					Text = TextStroke(CardHelper.GetDescription(props.CardId, props.Level)),
				}),
			}),
		}),

		Buttons = React.createElement(Container, {
			Size = UDim2.fromScale(0.7, 0.1),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
		}, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 12),
			}),

			Back = React.createElement(Button, {
				LayoutOrder = -1,
				Size = UDim2.fromScale(0.3, 1),
				[React.Event.Activated] = props.Close,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke("Back"),
				}),
			}),

			Toggle = React.createElement(Button, {
				LayoutOrder = -2,
				Size = UDim2.fromScale(0.3, 1),
				[React.Event.Activated] = props.Toggle,
				Active = props.Equipped or not props.DeckIsFull,
				ImageColor3 = if props.DeckIsFull and not props.Equipped then ColorDefs.PaleRed else ColorDefs.PaleGreen,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke(if props.Equipped then "Unequip" else if props.DeckIsFull then "<i>Full!</i>" else "Equip"),
				}),
			}),

			Equipped = React.createElement(Label, {
				LayoutOrder = -3,
				Size = UDim2.fromScale(0.3, 0.7),
				Text = TextStroke(if props.Equipped then "EQUIPPED" else "NOT EQUIPPED"),
			}),
		}),
	})
end

return function(props: {
	Visible: boolean,
	Close: () -> (),
	Deck: {
		Owned: { [string]: number },
		Equipped: { [string]: boolean },
	},
})
	local selectedId, setSelectedId = React.useState(nil)
	local equippedCount = Sift.Set.count(props.Deck.Equipped)
	local deckIsFull = equippedCount >= Configuration.DeckSizeMax

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke(`Deck ({equippedCount} / {Configuration.DeckSizeMax})`),
		[React.Event.Activated] = props.Close,
	}, {
		Details = (selectedId ~= nil) and React.createElement(cardDetails, {
			DeckIsFull = deckIsFull,
			CardId = selectedId,
			Level = props.Deck.Owned[selectedId],
			Equipped = props.Deck.Equipped[selectedId] == true,
			Close = function()
				setSelectedId(nil)
			end,
			Toggle = function()
				DeckController.CardEquipToggleRequested:Fire(selectedId)
			end,
		}),

		Cards = React.createElement(ScrollingFrame, {
			Visible = (selectedId == nil),
			RenderLayout = function(setCanvasSize)
				return React.createElement(GridLayout, {
					CellSize = UDim2.fromScale(1 / 4, 1),
					[React.Change.AbsoluteContentSize] = function(object)
						setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
					end,
				}, {
					Ratio = React.createElement(Aspect, {
						AspectRatio = 2.5 / 3.5,
					}),
				})
			end,
		}, {
			Cards = React.createElement(
				React.Fragment,
				nil,
				Sift.Dictionary.map(props.Deck.Owned, function(level, cardId)
					return React.createElement(LayoutContainer, {
						Padding = 6,
					}, {
						Button = React.createElement(Button, {
							ImageColor3 = if props.Deck.Equipped[cardId] then ColorDefs.PaleGreen else ColorDefs.PaleBlue,
							[React.Event.Activated] = function()
								setSelectedId(cardId)
							end,
							SelectionOrder = -1,
						}, {
							Contents = React.createElement(CardContents, {
								CardId = cardId,
								Level = level,
							}, {
								Check = props.Deck.Equipped[cardId] and React.createElement(Image, {
									Size = UDim2.fromScale(0.15, 0.15),
									ZIndex = 8,
									SizeConstraint = Enum.SizeConstraint.RelativeXX,
									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.fromScale(1, 0),
									Image = "rbxassetid://15360109124",
									ImageColor3 = ColorDefs.LightGreen,
								}),
							}),
						}),
					})
				end)
			),
		}),
	})
end
