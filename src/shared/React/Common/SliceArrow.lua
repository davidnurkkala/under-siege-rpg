local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	BackgroundTransparency = 1,
	ScaleType = Enum.ScaleType.Slice,
	Size = UDim2.fromScale(1, 1),
	Image = "rbxassetid://16247372808",
	SliceCenter = Rect.new(0, 50, 56, 124),
	AnchorPoint = Vector2.new(0.5, 0.5),
}

return function(props)
	return React.createElement("ImageLabel", Sift.Dictionary.merge(DefaultProps, props))
end
