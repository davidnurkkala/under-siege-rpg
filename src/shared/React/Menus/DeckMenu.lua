local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CardContents = require(ReplicatedStorage.Shared.React.Cards.CardContents)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local CardUpgradeResult = require(ReplicatedStorage.Shared.React.CardUpgrade.CardUpgradeResult)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Configuration = require(ReplicatedStorage.Shared.Configuration)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local DeckController = require(ReplicatedStorage.Shared.Controllers.DeckController)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local GuideController = require(ReplicatedStorage.Shared.Controllers.GuideController)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local RatioText = require(ReplicatedStorage.Shared.React.Common.RatioText)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseCheckPrice = require(ReplicatedStorage.Shared.React.Hooks.UseCheckPrice)
local UseCurrency = require(ReplicatedStorage.Shared.React.Hooks.UseCurrency)

function cardUpgradeReq(props: {
	LayoutOrder: number,
	CurrencyType: string,
	Amount: number,
})
	local owned = UseCurrency(props.CurrencyType)
	local name = CurrencyDefs[props.CurrencyType].Name

	return React.createElement(Container, {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 0.1),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
	}, {
		Layout = React.createElement(ListLayout, {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 12),
		}),

		Image = React.createElement(Panel, {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ImageColor3 = CurrencyDefs[props.CurrencyType].Colors.Primary,
		}, {
			Image = React.createElement(Image, {
				Image = CurrencyDefs[props.CurrencyType].Image,
			}),
		}),

		Text = React.createElement(Label, {
			LayoutOrder = 2,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.fromScale(0.8, 0.7),
			Text = TextStroke(`{owned} / {props.Amount} {name}`),
			TextColor3 = if owned < props.Amount then ColorDefs.PaleRed else nil,
		}),
	})
end

function cardDetails(props: {
	DeckIsFull: boolean,
	CardId: string,
	Level: number,
	Equipped: boolean,
	Close: () -> (),
	Upgrade: () -> (),
	Toggle: () -> (),
})
	local textRatio = 1 / 15
	local upgrade = CardHelper.GetUpgrade(props.CardId, props.Level)
	local canUpgrade = UseCheckPrice(upgrade)

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
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 8,
				ScrollBarImageColor3 = ColorDefs.Blue,
				RenderLayout = function(setCanvasSize)
					return React.createElement(ListLayout, {
						Padding = UDim.new(0, 6),
						[React.Change.AbsoluteContentSize] = function(object)
							setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y + 4))
						end,
					})
				end,
			}, {
				Padding = React.createElement("UIPadding", {
					PaddingRight = UDim.new(0, 12),
					PaddingLeft = UDim.new(0, 2),
				}),

				Text = React.createElement(RatioText, {
					LayoutOrder = 1,
					Ratio = textRatio,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					Text = TextStroke(CardHelper.GetDescription(props.CardId, props.Level)),
				}),

				Upgrade = (upgrade ~= nil) and React.createElement(React.Fragment, nil, {
					Text = React.createElement(RatioText, {
						LayoutOrder = 3,
						Ratio = textRatio,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = ColorDefs.Blue,
						Text = TextStroke(`To upgrade to Lv. {if CardHelper.HasUpgrade(props.CardId, props.Level + 1) then props.Level + 1 else "MAX"}:`),
					}),

					Reqs = React.createElement(
						React.Fragment,
						nil,
						Sift.Array.map(
							Sift.Array.sort(Sift.Dictionary.keys(upgrade), function(a, b)
								if upgrade[a] == upgrade[b] then
									return a > b
								else
									return upgrade[a] > upgrade[b]
								end
							end),
							function(currencyType, index)
								return React.createElement(cardUpgradeReq, {
									LayoutOrder = 3 + index,
									CurrencyType = currencyType,
									Amount = upgrade[currencyType],
								})
							end
						)
					),
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

			Upgrade = (upgrade ~= nil) and React.createElement(Button, {
				[React.Tag] = "GuiDeckCardDetailsUpgrade",
				LayoutOrder = -2,
				Size = UDim2.fromScale(0.3, 1),
				[React.Event.Activated] = props.Upgrade,
				Active = canUpgrade,
				ImageColor3 = if canUpgrade then ColorDefs.PaleGreen else ColorDefs.PaleRed,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke("Upgrade"),
				}),
			}),

			Toggle = React.createElement(Button, {
				LayoutOrder = -3,
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
				LayoutOrder = -4,
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
	local state, setState = React.useState("Menu")

	local upgrade = React.useCallback(function(id)
		setState("Waiting")
		DeckController.UpgradeCard(id):andThen(function(result)
			if not result then return end
			setState("ShowingUpgrade")
		end, function()
			setState("Menu")
		end)
	end, {})

	return React.createElement(Container, nil, {
		UpgradeResult = (state == "ShowingUpgrade") and React.createElement(CardUpgradeResult, {
			CardId = selectedId,
			Level = props.Deck.Owned[selectedId],
			Close = function()
				setState("Menu")

				-- hard code close when upgrading peasant from 1 to 2 for tutorial
				if selectedId == "Peasant" and props.Deck.Owned[selectedId] == 2 then props.Close() end
			end,
		}),

		UpgradePrompt = React.createElement(PromptWindow, {
			Visible = state == "PromptingUpgrade",

			HeaderText = TextStroke("Upgrade"),
			Text = TextStroke(`Are you sure you want to upgrade {CardHelper.GetName(selectedId)}?`),
			Options = {
				{
					Text = TextStroke("Yes"),
					Select = function()
						upgrade(selectedId)
					end,
				},
				{
					Text = TextStroke("No"),
					Select = function()
						setState("Menu")
					end,
				},
			},
			[React.Event.Activated] = function()
				setState("Menu")
			end,
		}),

		MainWindow = React.createElement(SystemWindow, {
			Visible = props.Visible and (state == "Menu"),
			HeaderText = TextStroke(`Army ({equippedCount} / {Configuration.DeckSizeMax})`),
			[React.Event.Activated] = props.Close,
			RatioDisabled = true,
			Size = UDim2.fromScale(1.2, 0.8),
			HeaderSize = 0.075,
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
				Upgrade = function()
					-- hard code skip the prompt for level 1 peasant for the tutorial
					if selectedId == "Peasant" and props.Deck.Owned[selectedId] == 1 then
						upgrade(selectedId)
						return
					end

					setState("PromptingUpgrade")
				end,
			}),

			Cards = React.createElement(ScrollingFrame, {
				Visible = (selectedId == nil),
				RenderLayout = function(setCanvasSize)
					return React.createElement(GridLayout, {
						CellSize = UDim2.fromScale(1 / 5, 1),
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
							[React.Tag] = `GuiDeckCardButton{cardId}`,
							Padding = 6,
						}, {
							Button = React.createElement(Button, {
								ImageColor3 = if props.Deck.Equipped[cardId] then ColorDefs.PaleGreen else ColorDefs.PaleBlue,
								[React.Event.Activated] = function()
									GuideController.GuiActionDone:Fire("DeckCardSelected", cardId)
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
		}),
	})
end
