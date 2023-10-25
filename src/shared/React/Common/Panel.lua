local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	Size = UDim2.fromScale(1, 1),
	BorderSizePixel = 0,
	BorderColor3 = Color3.new(0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	Image = "rbxassetid://15169414872",
	ScaleType = Enum.ScaleType.Crop,
}

return function(props)
	return React.createElement("ImageLabel", Sift.Dictionary.merge(DefaultProps, props), {
		Children = React.createElement(React.Fragment, nil, props.children),

		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),

		Stroke = React.createElement("UIStroke", {
			Color = props.BorderColor3 or Color3.new(0, 0, 0),
			Thickness = 2,
		}),
	})
end
