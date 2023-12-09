local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SquishWindow = require(ReplicatedStorage.Shared.React.Common.SquishWindow)

local Ratio = 16 / 9
local MaxSize = 280

local DefaultProps = {
	Visible = true,
	Position = UDim2.fromScale(0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromScale(0.4, 0.4),
	SizeConstraint = Enum.SizeConstraint.RelativeXX,
	HeaderText = "Prompt",
	HeaderSize = 0.2,
	BackgroundColor3 = ColorDefs.LightBlue,
	ImageColor3 = ColorDefs.PaleBlue,
}

return function(props: {
	Text: string,
	Options: any,
	Ratio: number?,
	TextSize: number?,
	children: any,
})
	local ratio = props.Ratio or Ratio
	local text = props.Text
	local options = props.Options
	local textSize = props.TextSize or 0.6

	props = Sift.Dictionary.removeKeys(props, "Ratio", "Text", "Options", "TextSize")

	local defaultProps = Sift.Dictionary.merge(DefaultProps, {
		RenderContainer = function()
			return React.createElement(React.Fragment, nil, {
				SizeConstraint = React.createElement("UISizeConstraint", {
					MaxSize = Vector2.new(MaxSize, MaxSize),
				}),
				Aspect = React.createElement(Aspect, {
					AspectRatio = ratio,
				}),
			})
		end,
	})

	local children = Sift.Dictionary.merge({
		Text = React.createElement(Label, {
			Size = UDim2.fromScale(1, textSize),
			Text = text,
		}),

		Buttons = React.createElement(Container, {
			Size = UDim2.fromScale(1, 1 - textSize),
			Position = UDim2.fromScale(0, textSize),
		}, {
			Layout = React.createElement(ListLayout, {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),

			Buttons = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map(options, function(option, index)
					return React.createElement(LayoutContainer, {
						Size = UDim2.fromScale(1 / #options, 1),
						LayoutOrder = index,
						Padding = 6,
					}, {
						Button = React.createElement(
							Button,
							Sift.Dictionary.merge(option.Props or {}, {
								[React.Event.Activated] = option.Select,
							}),
							{
								Text = React.createElement(Label, {
									Text = option.Text,
								}),
							}
						),
					})
				end)
			),
		}),
	}, props.children)

	return React.createElement(SquishWindow, Sift.Dictionary.merge(defaultProps, props), children)
end
