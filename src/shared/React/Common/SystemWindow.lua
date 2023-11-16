local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SquishWindow = require(ReplicatedStorage.Shared.React.Common.SquishWindow)

local Ratio = 16 / 9
local MaxSize = 540

local DefaultProps = {
	Visible = true,
	Position = UDim2.fromScale(0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromScale(0.8, 0.8),
	SizeConstraint = Enum.SizeConstraint.RelativeXX,
	HeaderText = "System",
	BackgroundColor3 = ColorDefs.LightBlue,
	ImageColor3 = ColorDefs.PaleBlue,
}

return function(props)
	local ratio = props.Ratio or Ratio
	props = Sift.Dictionary.removeKey(props, "Ratio")

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

	return React.createElement(SquishWindow, Sift.Dictionary.merge(defaultProps, props), props.children)
end
