local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Frame = require(ReplicatedStorage.Shared.React.Common.Frame)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)

return function(props: {
	LayoutOrder: number,
	Alignment: Enum.HorizontalAlignment,
	Percent: number,
})
	local isLeft = props.Alignment == Enum.HorizontalAlignment.Left

	return React.createElement(Panel, {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(0.3, 0.3),
		ImageColor3 = Color3.fromHex("#751212"),
		Corner = UDim.new(0, 8),
		Padding = UDim.new(0, 0),
	}, {
		Bar = React.createElement(Frame, {
			Size = UDim2.fromScale(props.Percent, 1),
			AnchorPoint = Vector2.new(if isLeft then 0 else 1, 0.5),
			Position = UDim2.fromScale(if isLeft then 0 else 1, 0.5),
			BackgroundColor3 = Color3.fromHex("#62CA7F"),
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end
