local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CardContents = require(ReplicatedStorage.Shared.React.Cards.CardContents)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local CelebrationEffect = require(ReplicatedStorage.Shared.React.Effects.CelebrationEffect)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local GuiSound = require(ReplicatedStorage.Shared.Util.GuiSound)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local Promise = require(ReplicatedStorage.Packages.Promise)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local CardWidth = 2.5 / 3.5
local Random = Random.new()
local FastSpring = { frequency = 16 }

return function(props: {
	Results: { { CardId: string, CountOld: number, CountNew: number, DidLevelUp: boolean } },
	Close: () -> (),
})
	local dx, dxMotor = UseMotor(0)
	local dy, dyMotor = UseMotor(-1)
	local width, widthMotor = UseMotor(1)
	local contentsVisible, setContentsVisible = React.useState(false)
	local buttonSize, buttonMotor = UseMotor(0)
	local isActive, setIsActive = React.useState(true)
	local platform = React.useContext(PlatformContext)

	local dismissCallback = React.useCallback(function()
		if not isActive then return end
		setIsActive(false)

		Promise.all({
			PromiseMotor(buttonMotor, Flipper.Spring.new(0, FastSpring), function(value)
				return value <= 0.05
			end),
			PromiseMotor(widthMotor, Flipper.Spring.new(0, FastSpring), function(value)
				return value <= 0.05
			end),
		}):andThenCall(props.Close)
	end, { isActive })

	React.useEffect(function()
		if not isActive then return end

		ContextActionService:BindActionAtPriority("DismissCardGachaResult", function(actionName, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

			dismissCallback()
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)

		return function()
			ContextActionService:UnbindAction("DismissCardGachaResult")
		end
	end, { isActive })

	local setDelta = React.useCallback(function(position)
		dxMotor:setGoal(Flipper.Spring.new(position.X))
		dyMotor:setGoal(Flipper.Spring.new(position.Y))
	end, { dxMotor, dyMotor })

	React.useEffect(function()
		setContentsVisible(false)

		GuiSound("RevealRiser1")

		local promise = Animate(0.8, function(scalar)
				local direction = Random:NextNumber(0, math.pi * 2)
				setDelta(Vector2.new(math.cos(direction) * scalar, math.sin(direction) * scalar) * 0.2)
			end)
			:andThen(function()
				setDelta(Vector2.new(0, 0))

				return PromiseMotor(widthMotor, Flipper.Spring.new(0, FastSpring), function(value)
					return value < 0.05
				end)
			end)
			:andThen(function()
				GuiSound("RevealImpact1")

				setContentsVisible(true)
				return PromiseMotor(widthMotor, Flipper.Spring.new(1, FastSpring), function(value)
					return value > 0.95
				end)
			end)
			:andThen(function()
				buttonMotor:setGoal(Flipper.Spring.new(1))
			end)

		return function()
			promise:cancel()
		end
	end, { props.Results })

	local cardProps = {
		Size = width:map(function(value)
			return UDim2.fromScale(0.5 * CardWidth * value, 0.5)
		end),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = React.joinBindings({ dx, dy }):map(function(values)
			return UDim2.fromScale(0.5, 0.4) + UDim2.fromScale(unpack(values))
		end),
	}

	return React.createElement(React.Fragment, nil, {
		CardBack = (not contentsVisible) and React.createElement(Panel, Sift.Dictionary.set(cardProps, "ImageColor3", ColorDefs.DarkGreen)),

		Card = contentsVisible and React.createElement(Container, cardProps, {
			Results = React.createElement(Container, nil, {
				Layout = React.createElement(ListLayout, {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 12),
				}),

				Results = React.createElement(
					React.Fragment,
					nil,
					Sift.Array.map(props.Results, function(result, index)
						local delta = result.CountNew - result.CountOld

						return React.createElement(Container, {
							LayoutOrder = index,
						}, {
							ChangeText = React.createElement(Label, {
								AnchorPoint = Vector2.new(0.5, 0),
								Position = UDim2.fromScale(0.5, 0),
								Size = UDim2.fromScale(0.8, 0.2),
								Text = TextStroke(`{if result.DidLevelUp then "Level up! " else ""}+{delta}`),
							}),

							Panel = React.createElement(Panel, {
								ImageColor3 = ColorDefs.PaleGreen,
								Size = UDim2.fromScale(0.8, 0.8),
								AnchorPoint = Vector2.new(0.5, 1),
								Position = UDim2.fromScale(0.5, 1),
							}, {
								Contents = React.createElement(CardContents, {
									CardId = result.CardId,
									CardCount = result.CountNew,
								}),
							}),
						})
					end)
				),
			}),

			Effect = React.createElement(Container, {
				ZIndex = -4,
				Size = UDim2.fromScale(1.5, 1.5),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			}, {
				Effect = React.createElement(CelebrationEffect),
			}),
		}),

		OkButton = React.createElement(Button, {
			ZIndex = 8,
			Visible = platform ~= "Console" and buttonSize:map(function(value)
				return value > 0
			end),
			Size = buttonSize:map(function(value)
				return UDim2.fromScale(0.2 * value, 0.05 * value)
			end),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.7),
			ImageColor3 = ColorDefs.PalePurple,
			[React.Event.Activated] = dismissCallback,
		}, {
			Label = React.createElement(Label, {
				Text = TextStroke("Okay"),
			}),
		}),

		OkayButtonGamepad = React.createElement("Frame", {
			Visible = platform == "Console" and width:map(function(value)
				return value > 0
			end),
			Size = width:map(function(value)
				return UDim2.fromScale(0.2 * value, 0.05)
			end),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.7),
			BackgroundTransparency = 1,
		}, {
			React.createElement(RoundButtonWithImage, {
				Visible = platform == "Console",
				[React.Event.Activated] = dismissCallback,
				Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonB),
				Text = "Back",
				height = UDim.new(1, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Selectable = false,
			}),
		}),
	})
end
