local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local Corner = UDim.new(0, 8)

return function(props)
	local borderSizePixel = props.BorderSizePixel or 2
	local borderColor3 = props.BorderColor3 or Color3.new(0, 0, 0)
	local headerText = props.HeaderText or "Window"
	local renderWindow = props.RenderWindow or function() end

	return React.createElement(
		"ImageLabel",
		Sift.Dictionary.merge(Sift.Dictionary.withKeys(props, "ZIndex", "Size", "SizeConstraint", "Position", "AnchorPoint", "ImageColor3", "LayoutOrder"), {
			Image = "rbxassetid://15169414872",
			ScaleType = Enum.ScaleType.Crop,
		}),
		{
			Corner = React.createElement("UICorner", {
				CornerRadius = Corner,
			}),

			Stroke = React.createElement("UIStroke", {
				Thickness = borderSizePixel,
				Color = borderColor3,
			}),

			Window = renderWindow(),

			Header = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.1),
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
						ImageColor3 = Color3.new(1, 0, 0),
						[React.Event.Activated] = props[React.Event.Activated],
					}, {
						Text = React.createElement(Label, {
							Size = UDim2.fromScale(2.5, 2.5),
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Text = TextStroke(`<b>X</b>`, 2),
						}),
					}),
				}),
			}),

			Content = React.createElement(Container, {
				Size = UDim2.new(1, 0, 0.9, -borderSizePixel),
				Position = UDim2.new(0, 0, 0.1, borderSizePixel),
			}, {
				Children = React.createElement(React.Fragment, nil, props.children),

				Padding = React.createElement(PaddingAll, {
					Padding = Corner,
				}),
			}),
		}
	)
end
