local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Frame = require(ReplicatedStorage.Shared.React.Common.Frame)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)

return function(props: {
	Alignment: Enum.HorizontalAlignment,
	Percent: number,
})
	local isLeft = props.Alignment == Enum.HorizontalAlignment.Left

	return React.createElement(Panel, {
		Size = UDim2.fromScale(1, 1),
		ImageColor3 = Color3.new(),
		Corner = UDim.new(0, 8),
		Padding = UDim.new(0, 0),
	}, {
		Bar = React.createElement(Frame, {
			Size = UDim2.fromScale(props.Percent, 1),
			AnchorPoint = Vector2.new(if isLeft then 0 else 1, 0.5),
			Position = UDim2.fromScale(if isLeft then 0 else 1, 0.5),
			BackgroundColor3 = ColorDefs.Green,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end
