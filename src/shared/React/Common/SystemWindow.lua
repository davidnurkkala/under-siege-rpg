local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SquishWindow = require(ReplicatedStorage.Shared.React.Common.SquishWindow)

local DefaultProps = {
	Visible = true,
	Position = UDim2.fromScale(0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromScale(0.8, 0.6),
	SizeConstraint = Enum.SizeConstraint.RelativeXX,
	HeaderText = "System",
	BackgroundColor3 = ColorDefs.LightBlue,
	ImageColor3 = ColorDefs.PaleBlue,

	RenderContainer = function()
		return React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(500, 300),
		})
	end,
}

return function(props)
	return React.createElement(SquishWindow, Sift.Dictionary.merge(DefaultProps, props), props.children)
end
