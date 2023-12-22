local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CelebrationEffect = require(ReplicatedStorage.Shared.React.Effects.CelebrationEffect)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local GuiSound = require(ReplicatedStorage.Shared.Util.GuiSound)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetPreview = require(ReplicatedStorage.Shared.React.PetGacha.PetPreview)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local Promise = require(ReplicatedStorage.Packages.Promise)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local function eggEffect(props: {
	EggId: string,
	OnFinished: () -> (),
})
	local viewportRef = React.useRef(nil)

	local size, setSize = React.useBinding(1)

	React.useEffect(function()
		local viewport = viewportRef.current
		if not viewport then return end

		local trove = Trove.new()

		local model = trove:Clone(ReplicatedStorage.Assets.Models.Eggs[props.EggId])
		model:PivotTo(CFrame.new())
		model.Parent = viewport

		local camera: Camera = trove:Construct(Instance, "Camera")
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 30
		camera.CFrame = CFrame.Angles(0, math.rad(135), 0) * CFrame.Angles(math.rad(-30), 0, 0) * CFrame.new(0, 0, 5)
		camera.Parent = viewport
		viewport.CurrentCamera = camera

		GuiSound("RevealRiser1")

		trove:AddPromise(Promise.all({
			Animate(0.9, function(scalar)
				local angle = math.pi * 0.4 * math.sin(math.pi * 8 * scalar) * (scalar ^ 2)
				viewport.Rotation = math.deg(angle)
			end),
			Promise.delay(0.7):andThenCall(Animate, 0.2, function(scalar)
				setSize(Lerp(1, 0, scalar ^ 2))
			end),
		}):andThenCall(props.OnFinished))

		return function()
			trove:Clean()
		end
	end, { props.EggId })

	return React.createElement("ViewportFrame", {
		BackgroundTransparency = 1,
		Size = size:map(function(value)
			return UDim2.fromScale(value, value)
		end),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ref = viewportRef,
	})
end

return function(props: {
	PetId: string,
	EggId: string,
	Close: () -> (),
})
	local petDef = PetDefs[props.PetId]

	local slide, slideMotor = UseMotor(-1)
	local size, sizeMotor = UseMotor(0)
	local width, widthMotor = UseMotor(0)
	local isActive, setIsActive = React.useState(true)
	local state, setState = React.useState("Egg")
	local platform = React.useContext(PlatformContext)

	local dismissCallback = React.useCallback(function()
		if not isActive then return end
		setIsActive(false)

		PromiseMotor(slideMotor, Flipper.Spring.new(-1), function(value)
			return value < -0.95
		end):andThenCall(props.Close)
	end, { isActive, props.Close })

	React.useEffect(function()
		if not isActive then return end

		ContextActionService:BindActionAtPriority("DismissPetGachaResult", function(actionName, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

			dismissCallback()
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)

		return function()
			ContextActionService:UnbindAction("DismissPetGachaResult")
		end
	end, { isActive })

	React.useEffect(function()
		slideMotor:setGoal(Flipper.Instant.new(-1))
		slideMotor:step()
		slideMotor:setGoal(Flipper.Spring.new(0))
	end, { props.PetId })

	return React.createElement(Container, {
		Position = slide:map(function(value)
			return UDim2.fromScale(0, value)
		end),
	}, {
		Result = React.createElement(Container, {
			Size = UDim2.fromScale(0.35, 0.35),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.4),
		}, {
			Egg = (state == "Egg") and React.createElement(eggEffect, {
				EggId = props.EggId,
				OnFinished = function()
					setState("Pet")

					PromiseMotor(sizeMotor, Flipper.Spring.new(1), function(value)
						return value > 0.95
					end):andThen(function()
						widthMotor:setGoal(Flipper.Spring.new(1))
					end)

					GuiSound("RevealImpact1")
				end,
			}),

			Contents = React.createElement(Container, {
				Visible = state == "Pet",
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = size:map(function(value)
					return UDim2.fromScale(value, value)
				end),
			}, {
				Name = React.createElement(Label, {
					Size = UDim2.fromScale(1, 0.2),
					Text = TextStroke(petDef.Name),
					ZIndex = 4,
				}),

				Preview = React.createElement(PetPreview, {
					PetId = props.PetId,
				}),
			}),

			Effect = (state == "Pet") and React.createElement(Container, {
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
			Visible = platform ~= "Console" and width:map(function(value)
				return value > 0
			end),
			Size = width:map(function(value)
				return UDim2.fromScale(0.2 * value, 0.05)
			end),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.6),
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
			Position = UDim2.fromScale(0.5, 0.6),
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
