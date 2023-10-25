local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	Image = "",
	BackgroundTransparency = 1,
	ScaleType = Enum.ScaleType.Fit,
	Size = UDim2.fromScale(1, 1),
}

return function(props)
	return React.createElement("ImageLabel", Sift.Dictionary.merge(DefaultProps, props))
end
