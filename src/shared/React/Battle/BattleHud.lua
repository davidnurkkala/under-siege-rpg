local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AttackButton = require(ReplicatedStorage.Shared.React.Battle.AttackButton)
local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CardContents = require(ReplicatedStorage.Shared.React.Cards.CardContents)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local ComponentController = require(ReplicatedStorage.Shared.Controllers.ComponentController)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Frame = require(ReplicatedStorage.Shared.React.Common.Frame)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local HealthBar = require(ReplicatedStorage.Shared.React.Battle.HealthBar)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local Promise = require(ReplicatedStorage.Packages.Promise)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local function getHealthPercent(status, index)
	return TryNow(function()
		local battler = status.Battlers[index]
		return battler.Health / battler.HealthMax
	end, 1)
end

local function healthBar(props: {
	LayoutOrder: number,
	Alignment: Enum.HorizontalAlignment,
	Percent: number,
})
	return React.createElement(Container, {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(0.3, 1),
	}, {
		Bar = React.createElement(HealthBar, {
			Alignment = props.Alignment,
			Percent = props.Percent,
		}),
	})
end

local function goonHealthBar(props: {
	GoonModel: any,
})
	local percent, setPercent = React.useState(1)
	local level, setLevel = React.useState(0)

	React.useEffect(function()
		local trove = Trove.new()

		local health = props.GoonModel.Health
		trove:Add(health:Observe(function()
			setPercent(health:GetPercent())
		end))

		trove:Add(Observers.observeAttribute(props.GoonModel.Root, "Level", setLevel))

		return function()
			trove:Clean()
		end
	end, { props.GoonModel })

	if percent <= 0 then return end

	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(6, 2),
		Adornee = props.GoonModel.OverheadPoint,
	}, {
		Level = React.createElement(Label, {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Text = TextStroke(level),
		}),
		HealthBar = React.createElement(Container, {
			Size = UDim2.fromScale(0.7, 0.25),
			Position = UDim2.fromScale(0.3, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
		}, {
			HealthBar = React.createElement(HealthBar, {
				Alignment = Enum.HorizontalAlignment.Left,
				Percent = percent,
			}),
		}),
	})
end

local function critBar(props: {
	Percent: number,
})
	local percent, percentMotor = UseMotor(0)

	React.useEffect(function()
		percentMotor:setGoal(Flipper.Spring.new(props.Percent))
	end, { props.Percent })

	return React.createElement(Panel, {
		BorderColor3 = Color3.new(),
		ImageColor3 = Color3.new(),
	}, {
		Bar = React.createElement(Frame, {
			Size = percent:map(function(value)
				return UDim2.fromScale(value, 1)
			end),
			BackgroundColor3 = ColorDefs.DarkRed,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

local function playedCard(props: {
	Guid: string,
	CardId: string,
	CardCount: number,
	AnchorPoint: Vector2,
	Finish: () -> (),
})
	local slide, slideMotor = UseMotor(0)
	local slidingDown = React.useRef(false)

	local width = 0.1
	local height = width * (3.5 / 2.5)

	React.useEffect(function()
		local promise = PromiseMotor(slideMotor, Flipper.Spring.new(1), function(value)
				return value > 0.99
			end)
			:andThenCall(Promise.delay, 3)
			:andThen(function()
				slidingDown.current = true
				return PromiseMotor(slideMotor, Flipper.Spring.new(0), function(value)
					return value < 0.01
				end)
			end)
			:andThenCall(props.Finish)

		return function()
			slideMotor:setGoal(Flipper.Instant.new(0))
			slideMotor:step()
			slidingDown.current = false

			promise:cancel()
		end
	end, { props.Guid, props.CardId, props.CardCount, props.Finish })

	return React.createElement(Panel, {
		ImageColor3 = ColorDefs.PaleGreen,
		Size = UDim2.fromScale(width, height),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		AnchorPoint = props.AnchorPoint,
		Position = slide:map(function(value)
			local isLeft = props.AnchorPoint.X == 0

			if slidingDown.current then
				return UDim2.fromScale(if isLeft then 0 else 1, Lerp(2, 1, value))
			else
				if isLeft then
					return UDim2.fromScale(Lerp(-0.5, 0, value), 1)
				else
					return UDim2.fromScale(Lerp(1.5, 1, value), 1)
				end
			end
		end),
	}, {
		Contents = React.createElement(CardContents, {
			CardId = props.CardId,
			CardCount = props.CardCount,
		}),
	})
end

local function broadcast(props: {
	Message: string?,
	Finish: () -> (),
})
	local chars, charsMotor = UseMotor(0)

	React.useEffect(function()
		charsMotor:setGoal(Flipper.Instant.new(0))
		charsMotor:step()

		if not props.Message then return end

		local count = 0
		for _ in utf8.graphemes(props.Message) do
			count += 1
		end

		local promise = PromiseMotor(charsMotor, Flipper.Spring.new(count, { frequency = 2 }), function(value)
			return math.abs(value - count) < 0.1
		end):andThenCall(Promise.delay, 3):andThenCall(props.Finish)

		return function()
			promise:cancel()
		end
	end, { props.Message, props.Finish })

	return props.Message
		and React.createElement(Label, {
			Text = TextStroke(props.Message),
			MaxVisibleGraphemes = chars:map(function(value)
				return math.round(value)
			end),
			Size = UDim2.fromScale(1, 0.1),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
		})
end

return function(props: {
	Visible: boolean,
})
	local status, setStatus = React.useState(nil)
	local goonModels, setGoonModels = React.useState({})
	local surrendering, setSurrendering = React.useState(false)
	local message, setMessage = React.useState(nil)
	local surrenderButtonRef = React.useRef(nil)
	local platform = React.useContext(PlatformContext)

	local clearMessage = React.useCallback(function()
		setMessage(nil)
	end, { setMessage })

	React.useEffect(function()
		if not props.Visible then return end
		if surrendering then return end

		ContextActionService:BindActionAtPriority("SelectSurrender", function(_, inputState)
			if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

			setSurrendering(true)
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonSelect)

		return function()
			ContextActionService:UnbindAction("SelectSurrender")
		end
	end, { props.Visible, surrendering })

	local leftCard, setLeftCard = React.useState(nil)
	local finishLeft = React.useCallback(function()
		setLeftCard(nil)
	end, {})

	local rightCard, setRightCard = React.useState(nil)
	local finishRight = React.useCallback(function()
		setRightCard(nil)
	end, {})

	local critEnabled = if status then status.CritEnabled else false

	React.useEffect(function()
		if not props.Visible then return end

		return BattleController:ObserveStatus(setStatus)
	end, { props.Visible })

	React.useEffect(function()
		if not props.Visible then return end

		local function update()
			setGoonModels(Sift.Dictionary.map(ComponentController:GetComponentsByName("GoonModel"), function(goonModel)
				return goonModel, goonModel.Guid
			end))
		end

		local stopObserving = ComponentController:ObserveClass("GoonModel", function()
			update()
			return update
		end)

		return function()
			stopObserving()
			setGoonModels({})
		end
	end, { props.Visible })

	React.useEffect(function()
		if not props.Visible then
			setLeftCard(nil)
			setRightCard(nil)
			return
		end

		local trove = Trove.new()

		trove:Connect(BattleController.CardPlayed, function(cardData)
			local data = Sift.Dictionary.set(Sift.Dictionary.removeKey(cardData, "Position"), "Guid", Guid())
			if cardData.Position < 0.5 then
				setLeftCard(data)
			else
				setRightCard(data)
			end
		end)

		trove:Connect(BattleController.MessageSent, function(messageIn)
			setMessage(messageIn)
		end)

		return function()
			trove:Clean()
		end
	end, { props.Visible })

	return React.createElement(Container, {
		Visible = props.Visible,
	}, {
		GoonHealthBars = React.createElement(
			"Folder",
			nil,
			Sift.Dictionary.map(goonModels, function(goonModel)
				return React.createElement(goonHealthBar, {
					GoonModel = goonModel,
				})
			end)
		),

		Message = React.createElement(broadcast, {
			Message = message,
			Finish = clearMessage,
		}),

		Bottom = React.createElement(Container, {}, {
			Padding = React.createElement("UIPadding", {
				PaddingBottom = UDim.new(0.075, 0),
			}),

			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0, 8),
			}),

			Hint = critEnabled
				and React.createElement(Label, {
					Text = TextStroke(
						`{if platform == "Desktop" then "Hold left click" else if platform == "Console" then "Hold RT" else "Tap and hold the attack button"} to charge a crit!`
					),
					Size = UDim2.fromScale(0.5, 0.025),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
				}),

			CritBar = critEnabled and React.createElement(Container, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.25, 0.025),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
			}, {
				Bar = React.createElement(critBar, {
					Percent = TryNow(function()
						return status.Battlers[1].Crit
					end, 0),
				}),
			}),

			Bars = React.createElement(Container, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0.05),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 0.9),
			}, {
				Layout = React.createElement(ListLayout, {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = if critEnabled then UDim.new(0, 8) else UDim.new(0, 24),
				}),

				AttackButton = critEnabled and React.createElement(AttackButton, {
					LayoutOrder = 2,
				}),

				HealthLeft = React.createElement(healthBar, {
					LayoutOrder = 1,
					Alignment = Enum.HorizontalAlignment.Right,
					Percent = getHealthPercent(status, 1),
				}),

				HealthRight = React.createElement(healthBar, {
					LayoutOrder = 3,
					Alignment = Enum.HorizontalAlignment.Left,
					Percent = getHealthPercent(status, 2),
				}),
			}),
		}),

		SurrenderPrompt = React.createElement(PromptWindow, {
			Visible = surrendering,

			HeaderText = TextStroke("Surrender"),
			Text = TextStroke("Are you sure you want to surrender?"),
			Options = {
				{
					Text = TextStroke("Yes"),
					Select = function()
						GuiService.SelectedObject = nil
						setSurrendering(false)
						BattleController.SurrenderRequested:Fire()
					end,
				},
				{
					Text = TextStroke("No"),
					Select = function()
						GuiService.SelectedObject = nil
						setSurrendering(false)
					end,
				},
			},
			[React.Event.Activated] = function()
				GuiService.SelectedObject = nil
				setSurrendering(false)
			end,
			buttonRef = surrenderButtonRef,
		}),

		Surrender = React.createElement(Button, {
			Visible = not surrendering,
			Size = UDim2.fromScale(0.1, 0.1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ImageColor3 = ColorDefs.PaleGreen,
			BorderColor3 = ColorDefs.LightGreen,
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			[React.Event.Activated] = function()
				setSurrendering(true)
			end,
			buttonRef = surrenderButtonRef,
			Selectable = false,
		}, {
			Image = React.createElement(Image, {
				Image = "rbxassetid://15484464238",
			}),
			GamepadHint = React.createElement(RoundButtonWithImage, {
				Visible = platform == "Console",
				Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonSelect),
				Text = "Surrender",
				Selectable = false,
				Position = UDim2.new(0.5, 0, 0, -4),
				AnchorPoint = Vector2.new(0.5, 1),
				height = UDim.new(0.4, 0),
			}),
		}),

		PlayedCards = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.85),
		}, {
			Left = (leftCard ~= nil) and React.createElement(
				playedCard,
				Sift.Dictionary.merge(leftCard, {
					AnchorPoint = Vector2.new(0, 1),
					Finish = finishLeft,
				})
			),

			Right = (rightCard ~= nil) and React.createElement(
				playedCard,
				Sift.Dictionary.merge(rightCard, {
					AnchorPoint = Vector2.new(1, 1),
					Finish = finishRight,
				})
			),
		}),
	})
end
