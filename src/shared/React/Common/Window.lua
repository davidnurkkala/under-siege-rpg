local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local Corner = UDim.new(0, 8)

return function(props)
	local borderSizePixel = props.BorderSizePixel or 2
	local borderColor3 = props.BorderColor3 or Color3.new(0, 0, 0)
	local headerText = props.HeaderText or "Window"
	local headerSize = props.HeaderSize or 0.1
	local windowRef = props.windowRef
	local interactable = if props.interactable == nil then true else props.interactable

	local platform = React.useContext(PlatformContext)

	React.useEffect(function()
		if not interactable then return end

		local bindKey = HttpService:GenerateGUID(false)
		ContextActionService:BindActionAtPriority(bindKey, function(actionName, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

			if props[React.Event.Activated] then props[React.Event.Activated]() end
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB, Enum.KeyCode.ButtonSelect)

		return function()
			ContextActionService:UnbindAction(bindKey)
		end
	end, { props[React.Event.Activated], interactable })

	return React.createElement(
		"ImageLabel",
		Sift.Dictionary.merge(Sift.Dictionary.withKeys(props, "ZIndex", "Size", "SizeConstraint", "Position", "AnchorPoint", "ImageColor3", "LayoutOrder"), {
			Image = "rbxassetid://15169414872",
			ScaleType = Enum.ScaleType.Crop,
			ref = windowRef,
		}),
		{
			Corner = React.createElement("UICorner", {
				CornerRadius = Corner,
			}),

			Stroke = React.createElement("UIStroke", {
				Thickness = borderSizePixel,
				Color = borderColor3,
			}),

			Window = if props.RenderWindow then React.createElement(props.RenderWindow) else nil,

			Header = React.createElement("Frame", {
				Size = UDim2.fromScale(1, headerSize),
				BackgroundColor3 = props.BackgroundColor3,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = Corner,
				}),

				Block = React.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					BorderSizePixel = 0,
					BackgroundColor3 = props.BackgroundColor3,
				}),

				Border = React.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, borderSizePixel),
					BorderSizePixel = 0,
					BackgroundColor3 = borderColor3,
					Position = UDim2.fromScale(0, 1),
				}),

				HeaderContent = React.createElement(Container, {
					Size = UDim2.fromScale(1, 1),
					ZIndex = 4,
				}, {
					Padding = React.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
					}),

					Text = React.createElement(Label, {
						Size = UDim2.fromScale(1, 1),
						Text = headerText,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 4,
					}),

					CloseButton = React.createElement(Button, {
						Size = UDim2.fromScale(0.8, 0.8),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						BorderSizePixel = borderSizePixel,
						Padding = UDim.new(0, 0),
						ImageColor3 = Color3.new(1, 0, 0),
						[React.Event.Activated] = interactable and props[React.Event.Activated],
						Selectable = interactable,
						Visible = platform ~= "Console",
					}, {
						Text = React.createElement(Label, {
							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Text = TextStroke(`<b>X</b>`, 2),
						}),
					}),
				}),
			}),

			GamepadHint = React.createElement(RoundButtonWithImage, {
				Visible = platform == "Console",
				[React.Event.Activated] = interactable and props[React.Event.Activated],
				Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonB),
				Text = "Back",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 1, 8),
				height = UDim.new(headerSize, 0),
				Selectable = false,
			}),

			Content = React.createElement(Container, {
				Size = UDim2.new(1, 0, 1 - headerSize, -borderSizePixel),
				Position = UDim2.new(0, 0, headerSize, borderSizePixel),
			}, {
				Children = React.createElement(React.Fragment, nil, props.children),

				Padding = React.createElement(PaddingAll, {
					Padding = Corner,
				}),
			}),
		}
	)
end
